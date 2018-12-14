//
//  XMLKeyedEncodingContainer.swift
//  XMLCoder
//
//  Created by Vincent Esche on 11/20/18.
//

import Foundation

internal struct _XMLKeyedEncodingContainer<K : CodingKey> : KeyedEncodingContainerProtocol {
    typealias Key = K
    
    // MARK: Properties
    
    /// A reference to the encoder we're writing to.
    private let encoder: _XMLEncoder
    
    /// A reference to the container we're writing to.
    private let container: NSMutableDictionary
    
    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]
    
    // MARK: - Initialization
    
    /// Initializes `self` with the given references.
    internal init(referencing encoder: _XMLEncoder, codingPath: [CodingKey], wrapping container: NSMutableDictionary) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    // MARK: - Coding Path Operations
    
    private func _converted(_ key: CodingKey) -> CodingKey {
        switch encoder.options.keyEncodingStrategy {
        case .useDefaultKeys:
            return key
        case .convertToSnakeCase:
            let newKeyString = XMLEncoder.KeyEncodingStrategy._convertToSnakeCase(key.stringValue)
            return _XMLKey(stringValue: newKeyString, intValue: key.intValue)
        case .custom(let converter):
            return converter(codingPath + [key])
        }
    }
    
    // MARK: - KeyedEncodingContainerProtocol Methods
    
    public mutating func encodeNil(forKey key: Key) throws {
        self.container[_converted(key).stringValue] = NSNull()
    }
    
    public mutating func encode(_ value: Bool, forKey key: Key) throws {
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = self.encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = self.encoder.box(value)
                self.container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            self.container[_converted(key).stringValue] = self.encoder.box(value)
        }
    }
    
    public mutating func encode<T: FixedWidthInteger & Encodable>(_ value: T, forKey key: Key) throws {
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = try self.encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = try self.encoder.box(value)
                self.container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            self.container[_converted(key).stringValue] = try self.encoder.box(value)
        }
    }
    
    public mutating func encode(_ value: String, forKey key: Key) throws {
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = self.encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = self.encoder.box(value)
                self.container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            self.container[_converted(key).stringValue] = self.encoder.box(value)
        }
    }
    
    public mutating func encode(_ value: Float, forKey key: Key) throws {
        // Since the float may be invalid and throw, the coding path needs to contain this key.
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        self.container[_converted(key).stringValue] = try self.encoder.box(value)
    }
    
    public mutating func encode(_ value: Double, forKey key: Key) throws {
        // Since the double may be invalid and throw, the coding path needs to contain this key.
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = try self.encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = try self.encoder.box(value)
                self.container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            self.container[_converted(key).stringValue] = try self.encoder.box(value)
        }
    }
    
    public mutating func encode<T : Encodable>(_ value: T, forKey key: Key) throws {
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        self.encoder.codingPath.append(key)
        let nodeEncodings = self.encoder.options.nodeEncodingStrategy.nodeEncodings(
            forType: T.self,
            with: self.encoder
        )
        self.encoder.nodeEncodings.append(nodeEncodings)
        defer {
            let _ = self.encoder.nodeEncodings.removeLast()
            self.encoder.codingPath.removeLast()
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = try self.encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = try self.encoder.box(value)
                self.container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            self.container[_converted(key).stringValue] = try self.encoder.box(value)
        }
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let dictionary = NSMutableDictionary()
        self.container[_converted(key).stringValue] = dictionary
        
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        
        let container = _XMLKeyedEncodingContainer<NestedKey>(referencing: self.encoder, codingPath: self.codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }
    
    public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let array = NSMutableArray()
        self.container[_converted(key).stringValue] = array
        
        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        return _XMLUnkeyedEncodingContainer(referencing: self.encoder, codingPath: self.codingPath, wrapping: array)
    }
    
    public mutating func superEncoder() -> Encoder {
        return _XMLReferencingEncoder(referencing: self.encoder, key: _XMLKey.super, convertedKey: _converted(_XMLKey.super), wrapping: self.container)
    }
    
    public mutating func superEncoder(forKey key: Key) -> Encoder {
        return _XMLReferencingEncoder(referencing: self.encoder, key: key, convertedKey: _converted(key), wrapping: self.container)
    }
}
