////
////  XMLDecoder.swift
////  CustomEncoder
////
////  Created by Shawn Moore on 11/14/17.
////  Copyright © 2017 Shawn Moore. All rights reserved.
////
//
//import Foundation
//
///// `XMLDecoder` facilitates the decoding of XML into semantic `Decodable` types.
//open class XMLDecoder {
//    // MARK: Options
//    /// The strategy to use for decoding `Date` values.
//    public enum DateDecodingStrategy {
//        /// Defer to `Date` for decoding. This is the default strategy.
//        case deferredToDate
//
//        /// Decode the `Date` as a UNIX timestamp from a XML number. This is the default strategy.
//        case secondsSince1970
//        
//        /// Decode the `Date` as UNIX millisecond timestamp from a XML number.
//        case millisecondsSince1970
//
//        /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
//        @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
//        case iso8601
//
//        /// Decode the `Date` as a string parsed by the given formatter.
//        case formatted(DateFormatter)
////
////        /// Decode the `Date` as a string parsed by the given formatter for the give key.
////        case keyFormatted((_ key: CodingKey) throws -> DateFormatter)
//
//        /// Decode the `Date` as a custom value decoded by the given closure.
//        case custom((_ decoder: Decoder) throws -> Date)
//    }
//
//    /// The strategy to use for decoding `Data` values.
//    public enum DataDecodingStrategy {
//        /// Defer to `Data` for decoding.
//        case deferredToData
//
//        /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
//        case base64
//
//        /// Decode the `Data` as a custom value decoded by the given closure.
//        case custom((_ decoder: Decoder) throws -> Data)
//    }
//
//    /// The strategy to use for non-XML-conforming floating-point values (IEEE 754 infinity and NaN).
//    public enum NonConformingFloatDecodingStrategy {
//        /// Throw upon encountering non-conforming values. This is the default strategy.
//        case `throw`
//
//        /// Decode the values from the given representation strings.
//        case convertFromString(positiveInfinity: String, negativeInfinity: String, nan: String)
//    }
//
//    /// The strategy to use in decoding dates. Defaults to `.secondsSince1970`.
//    open var dateDecodingStrategy: DateDecodingStrategy = .secondsSince1970
//
//    /// The strategy to use in decoding binary data. Defaults to `.base64`.
//    open var dataDecodingStrategy: DataDecodingStrategy = .base64
//
//    /// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
//    open var nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw
//
//    /// Contextual user-provided information for use during decoding.
//    open var userInfo: [CodingUserInfoKey : Any] = [:]
//
//    /// Options set on the top-level encoder to pass down the decoding hierarchy.
//    fileprivate struct _Options {
//        let dateDecodingStrategy: DateDecodingStrategy
//        let dataDecodingStrategy: DataDecodingStrategy
//        let nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy
//        let userInfo: [CodingUserInfoKey : Any]
//    }
//
//    /// The options set on the top-level decoder.
//    fileprivate var options: _Options {
//        return _Options(dateDecodingStrategy: dateDecodingStrategy,
//                        dataDecodingStrategy: dataDecodingStrategy,
//                        nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
//                        userInfo: userInfo)
//    }
//
//    // MARK: - Constructing a XML Decoder
//    /// Initializes `self` with default strategies.
//    public init() {}
//
//    // MARK: - Decoding Values
//    /// Decodes a top-level value of the given type from the given XML representation.
//    ///
//    /// - parameter type: The type of the value to decode.
//    /// - parameter data: The data to decode from.
//    /// - returns: A value of the requested type.
//    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid XML.
//    /// - throws: An error if any value throws an error during decoding.
//    open func decode<T : Decodable>(_ type: T.Type, from data: Data) throws /*-> T*/ {
//
////        let topLevel: Any
////        do {
////            topLevel = try JSONSerialization.jsonObject(with: data)
////        } catch {
////            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid JSON.", underlyingError: error))
////        }
////
////        let decoder = _JSONDecoder(referencing: topLevel, options: self.options)
////        guard let value = try decoder.unbox(topLevel, as: type) else {
////            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value."))
////        }
////
////        return value
//    }
//}
//
//// MARK: - _XMLDecoder
//
//fileprivate class _XMLDecoder : Decoder {
//    // MARK: Properties
//
//    /// The decoder's storage.
//    fileprivate var storage: _XMLDecodingStorage
//
//    /// Options set on the top-level decoder.
//    fileprivate let options: XMLDecoder._Options
//
//    /// The path to the current point in encoding.
//    fileprivate(set) public var codingPath: [CodingKey]
//
//    /// Contextual user-provided information for use during encoding.
//    public var userInfo: [CodingUserInfoKey : Any] {
//        return self.options.userInfo
//    }
//
//    // MARK: - Initialization
//
//    /// Initializes `self` with the given top-level container and options.
//    fileprivate init(referencing container: _XMLNode, at codingPath: [CodingKey] = [], options: XMLDecoder._Options) {
//        self.storage = _XMLDecodingStorage()
//        self.storage.push(container: container)
//        self.codingPath = codingPath
//        self.options = options
//    }
//
//    // MARK: - Decoder Methods
//
//    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
//        guard !(self.storage.topContainer is NSNull) else {
//            throw DecodingError.valueNotFound(KeyedDecodingContainer<Key>.self,
//                                              DecodingError.Context(codingPath: self.codingPath,
//                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
//        }
//
//        guard let topContainer = self.storage.topContainer as? [String : Any] else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [String : Any].self, reality: self.storage.topContainer)
//        }
//
//        let container = _XMLKeyedDecodingContainer<Key>(referencing: self, wrapping: topContainer)
//        return KeyedDecodingContainer(container)
//    }
//
//    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
//        guard !(self.storage.topContainer is NSNull) else {
//            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
//                                              DecodingError.Context(codingPath: self.codingPath,
//                                                                    debugDescription: "Cannot get unkeyed decoding container -- found null value instead."))
//        }
//
//        guard let topContainer = self.storage.topContainer as? [Any] else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [Any].self, reality: self.storage.topContainer)
//        }
//
//        return _XMLUnkeyedDecodingContainer(referencing: self, wrapping: topContainer)
//    }
//
//    public func singleValueContainer() throws -> SingleValueDecodingContainer {
//        return self
//    }
//}
//
//// MARK: - Decoding Storage
//
//fileprivate struct _XMLDecodingStorage {
//    // MARK: Properties
//
//    /// The container stack.
//    /// Elements may be any one of the XML types (String, [String : String]).
//    private(set) fileprivate var containers: [_XMLNode] = []
//
//    /// The container temporary value.
//    /// Elements can be of type Any.
//    fileprivate var temporaryValue: Any?
//
//    // MARK: - Initialization
//
//    /// Initializes `self` with no containers.
//    fileprivate init() {}
//
//    // MARK: - Modifying the Stack
//
//    fileprivate var count: Int {
//        return self.containers.count
//    }
//
//    fileprivate var topContainer: Any {
//        precondition(self.containers.count > 0, "Empty container stack.")
//        return self.containers.last!
//    }
//
//    fileprivate mutating func push(container: _XMLNode) {
//        self.containers.append(container)
//    }
//
//    fileprivate mutating func popContainer() {
//        precondition(self.containers.count > 0, "Empty container stack.")
//        self.containers.removeLast()
//    }
//}
//
//// MARK: Decoding Containers
//
//fileprivate struct _XMLKeyedDecodingContainer<K : CodingKey> : KeyedDecodingContainerProtocol {
//    typealias Key = K
//
//    // MARK: Properties
//
//    /// A reference to the decoder we're reading from.
//    private let decoder: _XMLDecoder
//
//    /// A reference to the container we're reading from.
//    private let container: _XMLNode
//
//    /// The path of coding keys taken to get to this point in decoding.
//    private(set) public var codingPath: [CodingKey]
//
//    // MARK: - Initialization
//
//    /// Initializes `self` by referencing the given decoder and container.
//    fileprivate init(referencing decoder: _XMLDecoder, wrapping container: _XMLNode) {
//        self.decoder = decoder
//        self.container = container
//        self.codingPath = decoder.codingPath
//    }
//
//    // MARK: - KeyedDecodingContainerProtocol Methods
//
//    public var allKeys: [Key] {
//        return self.container.allKeys.flatMap { Key(stringValue: $0) }
//    }
//
//    public func contains(_ key: Key) -> Bool {
//        return self.container.attributes[key.stringValue] != nil || self.container.properties[key.stringValue] != nil
//    }
//
//    public func decodeNil(forKey key: Key) throws -> Bool {
//        return self.container.attributes[key.stringValue] == nil && self.container.properties[key.stringValue] == nil
//    }
//
//    public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: Bool.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: Int.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: Int8.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: Int16.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: Int32.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: Int64.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: UInt.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: UInt8.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: UInt16.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: UInt32.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: UInt64.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: Float.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: Double.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func decode(_ type: String.Type, forKey key: Key) throws -> String {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: String.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func decode<T : Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
//        guard let entry = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
//        }
//
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = try self.decoder.unbox(entry, as: type) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath, debugDescription: "Expected \(type) value but found null instead."))
//        }
//
//        return value
//    }
//
//    public func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key,
//                                            DecodingError.Context(codingPath: self.codingPath,
//                                                                  debugDescription: "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key \"\(key.stringValue)\""))
//        }
//
//        guard let dictionary = value as? [String : Any] else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [String : Any].self, reality: value)
//        }
//
//        let container = _XMLKeyedDecodingContainer<NestedKey>(referencing: self.decoder, wrapping: dictionary)
//        return KeyedDecodingContainer(container)
//    }
//
//    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let value = self.container[key.stringValue] else {
//            throw DecodingError.keyNotFound(key,
//                                            DecodingError.Context(codingPath: self.codingPath,
//                                                                  debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \"\(key.stringValue)\""))
//        }
//
//        guard let array = value as? [Any] else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [Any].self, reality: value)
//        }
//
//        return _XMLUnkeyedDecodingContainer(referencing: self.decoder, wrapping: array)
//    }
//
//    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
//        self.decoder.codingPath.append(key)
//        defer { self.decoder.codingPath.removeLast() }
//
//        let value: Any = self.container[key.stringValue] ?? NSNull()
//        return _XMLDecoder(referencing: value, at: self.decoder.codingPath, options: self.decoder.options)
//    }
//
//    public func superDecoder() throws -> Decoder {
//        return try _superDecoder(forKey: _XMLKey.super)
//    }
//
//    public func superDecoder(forKey key: Key) throws -> Decoder {
//        return try _superDecoder(forKey: key)
//    }
//}
//
//fileprivate struct _XMLUnkeyedDecodingContainer : UnkeyedDecodingContainer {
//    // MARK: Properties
//
//    /// A reference to the decoder we're reading from.
//    private let decoder: _XMLDecoder
//
//    /// A reference to the container we're reading from.
//    private let container: [Any]
//
//    /// The path of coding keys taken to get to this point in decoding.
//    private(set) public var codingPath: [CodingKey]
//
//    /// The index of the element we're about to decode.
//    private(set) public var currentIndex: Int
//
//    // MARK: - Initialization
//
//    /// Initializes `self` by referencing the given decoder and container.
//    fileprivate init(referencing decoder: _XMLDecoder, wrapping container: [Any]) {
//        self.decoder = decoder
//        self.container = container
//        self.codingPath = decoder.codingPath
//        self.currentIndex = 0
//    }
//
//    // MARK: - UnkeyedDecodingContainer Methods
//
//    public var count: Int? {
//        return self.container.count
//    }
//
//    public var isAtEnd: Bool {
//        return self.currentIndex >= self.count!
//    }
//
//    public mutating func decodeNil() throws -> Bool {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        if self.container[self.currentIndex] is NSNull {
//            self.currentIndex += 1
//            return true
//        } else {
//            return false
//        }
//    }
//
//    public mutating func decode(_ type: Bool.Type) throws -> Bool {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Bool.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func decode(_ type: Int.Type) throws -> Int {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func decode(_ type: Int8.Type) throws -> Int8 {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int8.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func decode(_ type: Int16.Type) throws -> Int16 {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int16.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func decode(_ type: Int32.Type) throws -> Int32 {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int32.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func decode(_ type: Int64.Type) throws -> Int64 {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Int64.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func decode(_ type: UInt.Type) throws -> UInt {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt8.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt16.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt32.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: UInt64.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func decode(_ type: Float.Type) throws -> Float {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Float.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func decode(_ type: Double.Type) throws -> Double {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: Double.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func decode(_ type: String.Type) throws -> String {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: String.self) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func decode<T : Decodable>(_ type: T.Type) throws -> T {
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Unkeyed container is at end."))
//        }
//
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard let decoded = try self.decoder.unbox(self.container[self.currentIndex], as: type) else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.decoder.codingPath + [_XMLKey(index: self.currentIndex)], debugDescription: "Expected \(type) but found null instead."))
//        }
//
//        self.currentIndex += 1
//        return decoded
//    }
//
//    public mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
//                                              DecodingError.Context(codingPath: self.codingPath,
//                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
//        }
//
//        let value = self.container[self.currentIndex]
//        guard !(value is NSNull) else {
//            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self,
//                                              DecodingError.Context(codingPath: self.codingPath,
//                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
//        }
//
//        guard let dictionary = value as? [String : Any] else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [String : Any].self, reality: value)
//        }
//
//        self.currentIndex += 1
//        let container = _XMLKeyedDecodingContainer<NestedKey>(referencing: self.decoder, wrapping: dictionary)
//        return KeyedDecodingContainer(container)
//    }
//
//    public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
//                                              DecodingError.Context(codingPath: self.codingPath,
//                                                                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."))
//        }
//
//        let value = self.container[self.currentIndex]
//        guard !(value is NSNull) else {
//            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
//                                              DecodingError.Context(codingPath: self.codingPath,
//                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
//        }
//
//        guard let array = value as? [Any] else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [Any].self, reality: value)
//        }
//
//        self.currentIndex += 1
//        return _XMLUnkeyedDecodingContainer(referencing: self.decoder, wrapping: array)
//    }
//
//    public mutating func superDecoder() throws -> Decoder {
//        self.decoder.codingPath.append(_XMLKey(index: self.currentIndex))
//        defer { self.decoder.codingPath.removeLast() }
//
//        guard !self.isAtEnd else {
//            throw DecodingError.valueNotFound(Decoder.self,
//                                              DecodingError.Context(codingPath: self.codingPath,
//                                                                    debugDescription: "Cannot get superDecoder() -- unkeyed container is at end."))
//        }
//
//        let value = self.container[self.currentIndex]
//        self.currentIndex += 1
//        return _XMLDecoder(referencing: value, at: self.decoder.codingPath, options: self.decoder.options)
//    }
//}
//
//extension _XMLDecoder : SingleValueDecodingContainer {
//    // MARK: SingleValueDecodingContainer Methods
//
//    private func expectNonNull<T>(_ type: T.Type) throws {
//        guard !self.decodeNil() else {
//            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) but found null value instead."))
//        }
//    }
//
//    public func decodeNil() -> Bool {
//        return self.storage.topContainer is NSNull
//    }
//
//    public func decode(_ type: Bool.Type) throws -> Bool {
//        try expectNonNull(Bool.self)
//        return try self.unbox(self.storage.topContainer, as: Bool.self)!
//    }
//
//    public func decode(_ type: Int.Type) throws -> Int {
//        try expectNonNull(Int.self)
//        return try self.unbox(self.storage.topContainer, as: Int.self)!
//    }
//
//    public func decode(_ type: Int8.Type) throws -> Int8 {
//        try expectNonNull(Int8.self)
//        return try self.unbox(self.storage.topContainer, as: Int8.self)!
//    }
//
//    public func decode(_ type: Int16.Type) throws -> Int16 {
//        try expectNonNull(Int16.self)
//        return try self.unbox(self.storage.topContainer, as: Int16.self)!
//    }
//
//    public func decode(_ type: Int32.Type) throws -> Int32 {
//        try expectNonNull(Int32.self)
//        return try self.unbox(self.storage.topContainer, as: Int32.self)!
//    }
//
//    public func decode(_ type: Int64.Type) throws -> Int64 {
//        try expectNonNull(Int64.self)
//        return try self.unbox(self.storage.topContainer, as: Int64.self)!
//    }
//
//    public func decode(_ type: UInt.Type) throws -> UInt {
//        try expectNonNull(UInt.self)
//        return try self.unbox(self.storage.topContainer, as: UInt.self)!
//    }
//
//    public func decode(_ type: UInt8.Type) throws -> UInt8 {
//        try expectNonNull(UInt8.self)
//        return try self.unbox(self.storage.topContainer, as: UInt8.self)!
//    }
//
//    public func decode(_ type: UInt16.Type) throws -> UInt16 {
//        try expectNonNull(UInt16.self)
//        return try self.unbox(self.storage.topContainer, as: UInt16.self)!
//    }
//
//    public func decode(_ type: UInt32.Type) throws -> UInt32 {
//        try expectNonNull(UInt32.self)
//        return try self.unbox(self.storage.topContainer, as: UInt32.self)!
//    }
//
//    public func decode(_ type: UInt64.Type) throws -> UInt64 {
//        try expectNonNull(UInt64.self)
//        return try self.unbox(self.storage.topContainer, as: UInt64.self)!
//    }
//
//    public func decode(_ type: Float.Type) throws -> Float {
//        try expectNonNull(Float.self)
//        return try self.unbox(self.storage.topContainer, as: Float.self)!
//    }
//
//    public func decode(_ type: Double.Type) throws -> Double {
//        try expectNonNull(Double.self)
//        return try self.unbox(self.storage.topContainer, as: Double.self)!
//    }
//
//    public func decode(_ type: String.Type) throws -> String {
//        try expectNonNull(String.self)
//        return try self.unbox(self.storage.topContainer, as: String.self)!
//    }
//
//    public func decode<T : Decodable>(_ type: T.Type) throws -> T {
//        try expectNonNull(type)
//        return try self.unbox(self.storage.topContainer, as: type)!
//    }
//}
//
//// MARK: - Concrete Value Representations
//
//extension _XMLDecoder {
//    /// Returns the given value unboxed from a container.
//    fileprivate func unbox(_ value: String?, as type: Bool.Type) throws -> Bool? {
//        guard let value = value else { return nil }
//
//        if value == "true" || value == "1" {
//            return true
//        } else if value == "false" || value == "0" {
//            return false
//        }
//
//        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
//    }
//
//    fileprivate func unbox(_ value: String?, as type: Int.Type) throws -> Int? {
//        guard let string = value else { return nil }
//
//        guard let value = Float(string) else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let number = NSNumber(value: value)
//
//        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let int = number.intValue
//        guard NSNumber(value: int) == number else {
//            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
//        }
//
//        return int
//    }
//
//    fileprivate func unbox(_ value: String?, as type: Int16.Type) throws -> Int16? {
//        guard let string = value else { return nil }
//
//        guard let value = Float(string) else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let number = NSNumber(value: value)
//
//        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let int16 = number.int16Value
//        guard NSNumber(value: int16) == number else {
//            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
//        }
//
//        return int16
//    }
//
//    fileprivate func unbox(_ value: String?, as type: Int32.Type) throws -> Int32? {
//        guard let string = value else { return nil }
//
//        guard let value = Float(string) else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let number = NSNumber(value: value)
//
//        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let int32 = number.int32Value
//        guard NSNumber(value: int32) == number else {
//            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
//        }
//
//        return int32
//    }
//
//    fileprivate func unbox(_ value: String?, as type: Int64.Type) throws -> Int64? {
//        guard let string = value else { return nil }
//
//        guard let value = Float(string) else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let number = NSNumber(value: value)
//
//        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let int64 = number.int64Value
//        guard NSNumber(value: int64) == number else {
//            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
//        }
//
//        return int64
//    }
//
//    fileprivate func unbox(_ value: String?, as type: UInt.Type) throws -> UInt? {
//        guard let string = value else { return nil }
//
//        guard let value = Float(string) else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let number = NSNumber(value: value)
//
//        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let uint = number.uintValue
//        guard NSNumber(value: uint) == number else {
//            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
//        }
//
//        return uint
//    }
//
//    fileprivate func unbox(_ value: String?, as type: UInt8.Type) throws -> UInt8? {
//        guard let string = value else { return nil }
//
//        guard let value = Float(string) else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let number = NSNumber(value: value)
//
//        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let uint8 = number.uint8Value
//        guard NSNumber(value: uint8) == number else {
//            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
//        }
//
//        return uint8
//    }
//
//    fileprivate func unbox(_ value: String?, as type: UInt16.Type) throws -> UInt16? {
//        guard let string = value else { return nil }
//
//        guard let value = Float(string) else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let number = NSNumber(value: value)
//
//        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let uint16 = number.uint16Value
//        guard NSNumber(value: uint16) == number else {
//            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
//        }
//
//        return uint16
//    }
//
//    fileprivate func unbox(_ value: String?, as type: UInt32.Type) throws -> UInt32? {
//        guard let string = value else { return nil }
//
//        guard let value = Float(string) else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let number = NSNumber(value: value)
//
//        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let uint32 = number.uint32Value
//        guard NSNumber(value: uint32) == number else {
//            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
//        }
//
//        return uint32
//    }
//
//    fileprivate func unbox(_ value: String?, as type: UInt64.Type) throws -> UInt64? {
//        guard let string = value else { return nil }
//
//        guard let value = Float(string) else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let number = NSNumber(value: value)
//
//        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
//            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//        }
//
//        let uint64 = number.uint64Value
//        guard NSNumber(value: uint64) == number else {
//            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
//        }
//
//        return uint64
//    }
//
//    fileprivate func unbox(_ value: String?, as type: Float.Type) throws -> Float? {
//        guard let string = value else { return nil }
//
//        if let value = Double(string) {
//            let number = NSNumber(value: value)
//
//            guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
//                throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//            }
//
//            let double = number.doubleValue
//            guard abs(double) <= Double(Float.greatestFiniteMagnitude) else {
//                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number \(number) does not fit in \(type)."))
//            }
//
//            return Float(double)
//        } else if case let .convertFromString(posInfString, negInfString, nanString) = self.options.nonConformingFloatDecodingStrategy {
//            if string == posInfString {
//                return Float.infinity
//            } else if string == negInfString {
//                return -Float.infinity
//            } else if string == nanString {
//                return Float.nan
//            }
//        }
//
//        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//    }
//
//    fileprivate func unbox(_ value: String?, as type: Double.Type) throws -> Double? {
//        guard let string = value else { return nil }
//
//        if let number = Decimal(string: string) as NSDecimalNumber? {
//
//            guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
//                throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//            }
//
//            let double = number.doubleValue
//
//            guard NSNumber(value: double) == number else {
//                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed JSON number <\(number)> does not fit in \(type)."))
//            }
//
//            return double
//        } else if case let .convertFromString(posInfString, negInfString, nanString) = self.options.nonConformingFloatDecodingStrategy {
//            if string == posInfString {
//                return Double.infinity
//            } else if string == negInfString {
//                return -Double.infinity
//            } else if string == nanString {
//                return Double.nan
//            }
//        }
//
//        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
//    }
//
//    fileprivate func unbox(_ value: String?, as type: Date.Type) throws -> Date? {
//        guard let string = value else { return nil }
//
//        switch self.options.dateDecodingStrategy {
//        case .deferredToDate:
//            self.storage.temporaryValue = value
//            let date = try Date(from: self)
//            self.storage.temporaryValue = nil
//            return date
//
//        case .secondsSince1970:
//            let double = try self.unbox(value, as: Double.self)!
//            return Date(timeIntervalSince1970: double)
//
//        case .millisecondsSince1970:
//            let double = try self.unbox(value, as: Double.self)!
//            return Date(timeIntervalSince1970: double / 1000.0)
//
//        case .iso8601:
//            guard let date = _iso8601Formatter.date(from: string) else {
//                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
//            }
//
//            return date
//
//        case .formatted(let formatter):
//            guard let date = formatter.date(from: string) else {
//                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Date string does not match format expected by formatter."))
//            }
//
//            return date
//
//        case .custom(let closure):
//            self.storage.temporaryValue = value
//            let date = try closure(self)
//            self.storage.temporaryValue = nil
//            return date
//        }
//    }
//
//    fileprivate func unbox(_ value: String?, as type: Data.Type) throws -> Data? {
//        guard let string = value else { return nil }
//
//        switch self.options.dataDecodingStrategy {
//        case .deferredToData:
//            self.storage.temporaryValue = value
//            let data = try Data(from: self)
//            self.storage.temporaryValue = nil
//            return data
//
//        case .base64:
//            guard let data = Data(base64Encoded: string) else {
//                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encountered Data is not valid Base64."))
//            }
//
//            return data
//        case .custom(let closure):
//            self.storage.temporaryValue = value
//            let data = try closure(self)
//            self.storage.temporaryValue = nil
//            return data
//        }
//    }
//
//    fileprivate func unbox(_ value: String?, as type: Decimal.Type) throws -> Decimal? {
//        guard let string = value else { return nil }
//
//        return Decimal(string: string)
//    }
//
//    fileprivate func unbox<T : Decodable>(_ value: Any, as type: T.Type) throws -> T? {
//        let decoded: T?
//
//        if type == Date.self || type == NSDate.self {
//            guard let date = try self.unbox(value, as: Date.self) else { return nil }
//            decoded = date as? T
//        } else if type == Data.self || type == NSData.self {
//            guard let data = try self.unbox(value, as: Data.self) else { return nil }
//            decoded = data as? T
//        } else if type == URL.self || type == NSURL.self {
//            guard let urlString = try self.unbox(value, as: String.self) else {
//                return nil
//            }
//
//            guard let url = URL(string: urlString) else {
//                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath,
//                                                                        debugDescription: "Invalid URL string."))
//            }
//
//            decoded = (url as! T)
//        } else if type == Decimal.self || type == NSDecimalNumber.self {
//            guard let decimal = try self.unbox(value, as: Decimal.self) else { return nil }
//            decoded = decimal as? T
//        } else {
//            self.storage.temporaryValue = value
//            decoded = try type.init(from: self)
//            self.storage.temporaryValue = nil
//        }
//
//        return decoded
//    }
//}
//
////===----------------------------------------------------------------------===//
//// Shared Key Types
////===----------------------------------------------------------------------===//
//
//fileprivate struct _XMLKey : CodingKey {
//    public var stringValue: String
//    public var intValue: Int?
//
//    public init?(stringValue: String) {
//        self.stringValue = stringValue
//        self.intValue = nil
//    }
//
//    public init?(intValue: Int) {
//        self.stringValue = "\(intValue)"
//        self.intValue = intValue
//    }
//
//    fileprivate init(index: Int) {
//        self.stringValue = "Index \(index)"
//        self.intValue = index
//    }
//
//    fileprivate static let `super` = _XMLKey(stringValue: "super")!
//}
//
////===----------------------------------------------------------------------===//
//// Shared ISO8601 Date Formatter
////===----------------------------------------------------------------------===//
//
//// NOTE: This value is implicitly lazy and _must_ be lazy. We're compiled against the latest SDK (w/ ISO8601DateFormatter), but linked against whichever Foundation the user has. ISO8601DateFormatter might not exist, so we better not hit this code path on an older OS.
//@available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
//fileprivate var _iso8601Formatter: ISO8601DateFormatter = {
//    let formatter = ISO8601DateFormatter()
//    formatter.formatOptions = .withInternetDateTime
//    return formatter
//}()
//
////===----------------------------------------------------------------------===//
//// Error Utilities
////===----------------------------------------------------------------------===//
//
//fileprivate extension DecodingError {
//    /// Returns a `.typeMismatch` error describing the expected type.
//    ///
//    /// - parameter path: The path of `CodingKey`s taken to decode a value of this type.
//    /// - parameter expectation: The type expected to be encountered.
//    /// - parameter reality: The value that was encountered instead of the expected type.
//    /// - returns: A `DecodingError` with the appropriate path and debug description.
//    fileprivate static func _typeMismatch(at path: [CodingKey], expectation: Any.Type, reality: Any) -> DecodingError {
//        let description = "Expected to decode \(expectation) but found \(_typeDescription(of: reality)) instead."
//        return .typeMismatch(expectation, Context(codingPath: path, debugDescription: description))
//    }
//
//    /// Returns a description of the type of `value` appropriate for an error message.
//    ///
//    /// - parameter value: The value whose type to describe.
//    /// - returns: A string describing `value`.
//    /// - precondition: `value` is one of the types below.
//    fileprivate static func _typeDescription(of value: Any) -> String {
//        if value is NSNull {
//            return "a null value"
//        } else if value is NSNumber /* FIXME: If swift-corelibs-foundation isn't updated to use NSNumber, this check will be necessary: || value is Int || value is Double */ {
//            return "a number"
//        } else if value is String {
//            return "a string/data"
//        } else if value is [Any] {
//            return "an array"
//        } else if value is [String : Any] {
//            return "a dictionary"
//        } else {
//            return "\(type(of: value))"
//        }
//    }
//}
//
////===----------------------------------------------------------------------===//
//// Data Representation
////===----------------------------------------------------------------------===//
//
//fileprivate class _XMLNode {
//    var name = ""
//    var content: String?
//    var properties = [String:[_XMLNode]]()
//    var attributes = [String:String]()
//
//    var propertyKeys: [String] {
//        return Array(properties.keys)
//    }
//
//    var attributeKeys: [String] {
//        return Array(attributes.keys)
//    }
//
//    var allKeys: [String] {
//        return propertyKeys + attributeKeys
//    }
//}
//
//fileprivate class _XMLStackParser: NSObject, XMLParserDelegate {
//    var root: _XMLNode?
//    var stack = [_XMLNode]()
//    var currentNode: _XMLNode?
//
//    var currentElementName: String?
//    var currentElementData = ""
//
//    func parse(with data: Data) throws -> _XMLNode?  {
//        let xmlParser = XMLParser(data: data)
//        xmlParser.delegate = self
//
//        if xmlParser.parse() {
//            return root
//        } else if let error = xmlParser.parserError {
//            throw error
//        } else {
//            return nil
//        }
//    }
//
//    func parserDidStartDocument(_ parser: XMLParser) {
//        root = nil
//        stack = [_XMLNode]()
//    }
//
//    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
//        let node = _XMLNode()
//        node.name = elementName
//        node.attributes = attributeDict
//        stack.append(node)
//
//        if let currentNode = currentNode {
//            if currentNode.properties[elementName] != nil {
//                currentNode.properties[elementName]?.append(node)
//            } else {
//                currentNode.properties[elementName] = [node]
//            }
//        }
//        currentNode = node
//    }
//
//    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        if let poppedNode = stack.popLast(){
//            if let content = poppedNode.content?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
//                poppedNode.content = content
//            }
//
//            if (stack.isEmpty) {
//                root = poppedNode
//                currentNode = nil
//            } else {
//                currentNode = stack.last
//            }
//        }
//    }
//
//    func parser(_ parser: XMLParser, foundCharacters string: String) {
//        currentNode?.content = (currentNode?.content ?? "") + string
//    }
//
//    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
//        if let string = String(data: CDATABlock, encoding: .utf8) {
//            currentNode?.content = (currentNode?.content ?? "") + string
//        }
//    }
//
//    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
//        print(parseError)
//    }
//}
//
//
