//
//  XMLUnkeyedEncodingContainer.swift
//  XMLCoder
//
//  Created by Vincent Esche on 11/20/18.
//

import Foundation

internal struct _XMLUnkeyedEncodingContainer : UnkeyedEncodingContainer {
    // MARK: Properties
    
    /// A reference to the encoder we're writing to.
    private let encoder: _XMLEncoder
    
    /// A reference to the container we're writing to.
    private let container: UnkeyedBox
    
    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]
    
    /// The number of elements encoded into the container.
    public var count: Int {
        return self.container.count
    }
    
    // MARK: - Initialization
    
    /// Initializes `self` with the given references.
    internal init(referencing encoder: _XMLEncoder, codingPath: [CodingKey], wrapping container: UnkeyedBox) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    // MARK: - UnkeyedEncodingContainer Methods
    
    public mutating func encodeNil() throws {
        self.container.append(self.encoder.box())
    }
    
    public mutating func encode(_ value: Bool) throws {
        self.container.append(self.encoder.box(value))
    }
    
    public mutating func encode(_ value: Decimal) throws {
        self.container.append(self.encoder.box(value))
    }

    public mutating func encode<T: BinaryInteger & SignedInteger & Encodable>(_ value: T) throws {
        self.container.append(self.encoder.box(value))
    }
    
    public mutating func encode<T: BinaryInteger & UnsignedInteger & Encodable>(_ value: T) throws {
        self.container.append(self.encoder.box(value))
    }

    public mutating func encode<T: BinaryFloatingPoint & Encodable>(_ value: T)  throws {
        // Since the float/double may be invalid and throw, the coding path needs to contain this key.
        self.encoder.codingPath.append(_XMLKey(index: self.count))
        defer { self.encoder.codingPath.removeLast() }
        self.container.append(try self.encoder.box(value))
    }
    
    public mutating func encode(_ value: Date) throws {
        self.container.append(try self.encoder.box(value))
    }
    
    public mutating func encode(_ value: Data) throws {
        self.container.append(try self.encoder.box(value))
    }
    
    public mutating func encode(_ value: String) throws {
        self.container.append(self.encoder.box(value))
    }
    
    public mutating func encode<T: Encodable>(_ value: T) throws {
        self.encoder.codingPath.append(_XMLKey(index: self.count))
        defer { self.encoder.codingPath.removeLast() }
        self.container.append(try self.encoder.box(value))
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        self.codingPath.append(_XMLKey(index: self.count))
        defer { self.codingPath.removeLast() }
        
        let keyed = KeyedBox()
        self.container.append(keyed)
        
        let container = _XMLKeyedEncodingContainer<NestedKey>(referencing: self.encoder, codingPath: self.codingPath, wrapping: keyed)
        return KeyedEncodingContainer(container)
    }
    
    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self.codingPath.append(_XMLKey(index: self.count))
        defer { self.codingPath.removeLast() }
        
        let unkeyed = UnkeyedBox()
        self.container.append(unkeyed)
        
        return _XMLUnkeyedEncodingContainer(referencing: self.encoder, codingPath: self.codingPath, wrapping: unkeyed)
    }
    
    public mutating func superEncoder() -> Encoder {
        return _XMLReferencingEncoder(referencing: self.encoder, at: self.container.count, wrapping: self.container)
    }
}
