//
//  XMLKeyedDecodingContainer.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/21/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

/// Type-erased protocol helper for a metatype check in generic `decode`
/// overload.
private protocol AnyEmptySequence {
    init()
}

extension Array: AnyEmptySequence {}
extension Dictionary: AnyEmptySequence {}

// MARK: Decoding Containers

struct _XMLKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K

    // MARK: Properties

    /// A reference to the decoder we're reading from.
    private let decoder: _XMLDecoder

    /// A reference to the container we're reading from.
    private let container: KeyedBox

    /// The path of coding keys taken to get to this point in decoding.
    public private(set) var codingPath: [CodingKey]

    // MARK: - Initialization

    /// Initializes `self` by referencing the given decoder and container.
    init(referencing decoder: _XMLDecoder, wrapping container: KeyedBox) {
        self.decoder = decoder
        switch decoder.options.keyDecodingStrategy {
        case .useDefaultKeys:
            self.container = container
        case .convertFromSnakeCase:
            // Convert the snake case keys in the container to camel case.
            // If we hit a duplicate key after conversion, then we'll use the first one we saw. Effectively an undefined behavior with dictionaries.
            self.container = KeyedBox(container.map {
                key, value in (XMLDecoder.KeyDecodingStrategy._convertFromSnakeCase(key), value)
            }, uniquingKeysWith: { first, _ in first })
        case .convertFromCapitalized:
            self.container = KeyedBox(container.map {
                key, value in (XMLDecoder.KeyDecodingStrategy._convertFromCapitalized(key), value)
            }, uniquingKeysWith: { first, _ in first })
        case let .custom(converter):
            self.container = KeyedBox(container.map {
                key, value in (converter(decoder.codingPath + [_XMLKey(stringValue: key, intValue: nil)]).stringValue, value)
            }, uniquingKeysWith: { first, _ in first })
        }
        codingPath = decoder.codingPath
    }

    // MARK: - KeyedDecodingContainerProtocol Methods

    public var allKeys: [Key] {
        return container.keys.compactMap { Key(stringValue: $0) }
    }

    public func contains(_ key: Key) -> Bool {
        return container[key.stringValue] != nil
    }

    private func _errorDescription(of key: CodingKey) -> String {
        switch decoder.options.keyDecodingStrategy {
        case .convertFromSnakeCase:
            // In this case we can attempt to recover the original value by reversing the transform
            let original = key.stringValue
            let converted = XMLEncoder.KeyEncodingStrategy._convertToSnakeCase(original)
            if converted == original {
                return "\(key) (\"\(original)\")"
            } else {
                return "\(key) (\"\(original)\"), converted to \(converted)"
            }
        default:
            // Otherwise, just report the converted string
            return "\(key) (\"\(key.stringValue)\")"
        }
    }

    public func decodeNil(forKey key: Key) throws -> Bool {
        if let entry = container[key.stringValue] {
            return entry.isNull
        } else {
            return true
        }
    }

    public func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        return try self.decode(type, forKey: key) { decoder, box in
            return try decoder.unbox(box)
        }
    }

    public func decode(_ type: Decimal.Type, forKey key: Key) throws -> Decimal {
        return try self.decode(type, forKey: key) { decoder, box in
            return try decoder.unbox(box)
        }
    }

    public func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        return try self.decodeSignedInteger(type, forKey: key)
    }

    public func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        return try self.decodeSignedInteger(type, forKey: key)
    }

    public func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        return try self.decodeSignedInteger(type, forKey: key)
    }

    public func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        return try self.decodeSignedInteger(type, forKey: key)
    }

    public func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        return try self.decodeSignedInteger(type, forKey: key)
    }

    public func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        return try self.decodeUnsignedInteger(type, forKey: key)
    }

    public func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        return try self.decodeUnsignedInteger(type, forKey: key)
    }

    public func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        return try self.decodeUnsignedInteger(type, forKey: key)
    }

    public func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        return try self.decodeUnsignedInteger(type, forKey: key)
    }

    public func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        return try self.decodeUnsignedInteger(type, forKey: key)
    }

    public func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        return try self.decodeFloatingPoint(type, forKey: key)
    }

    public func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        return try self.decodeFloatingPoint(type, forKey: key)
    }

    public func decode(_ type: String.Type, forKey key: Key) throws -> String {
        return try self.decode(type, forKey: key) { decoder, box in
            return try decoder.unbox(box)
        }
    }

    public func decode(_ type: Date.Type, forKey key: Key) throws -> Date {
        return try self.decode(type, forKey: key) { decoder, box in
            return try decoder.unbox(box)
        }
    }

    public func decode(_ type: Data.Type, forKey key: Key) throws -> Data {
        return try self.decode(type, forKey: key) { decoder, box in
            return try decoder.unbox(box)
        }
    }

    public func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        if type is AnyEmptySequence.Type && container[key.stringValue] == nil {
            return (type as! AnyEmptySequence.Type).init() as! T
        }

        return try self.decode(type, forKey: key) { decoder, box in
            return try decoder.unbox(box)
        }
    }

    private func decodeSignedInteger<T: BinaryInteger & SignedInteger & Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        return try self.decode(type, forKey: key) { decoder, box in
            return try decoder.unbox(box)
        }
    }

    private func decodeUnsignedInteger<T: BinaryInteger & UnsignedInteger & Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        return try self.decode(type, forKey: key) { decoder, box in
            return try decoder.unbox(box)
        }
    }

    private func decodeFloatingPoint<T: BinaryFloatingPoint & Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        return try self.decode(type, forKey: key) { decoder, box in
            return try decoder.unbox(box)
        }
    }

    private func decode<T: Decodable>(
        _ type: T.Type,
        forKey key: Key,
        decode: (_XMLDecoder, Box) throws -> T?
    ) throws -> T {
        guard let entry = container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "No value associated with key \(_errorDescription(of: key))."
            ))
        }

        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        guard let value: T = try decoder.unbox(entry) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected \(type) value but found null instead."
            ))
        }

        return value
    }

    public func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        guard let value = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key \"\(key.stringValue)\""
            ))
        }

        guard let keyed = value as? KeyedBox else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [String: Any].self, reality: value)
        }

        let container = _XMLKeyedDecodingContainer<NestedKey>(referencing: decoder, wrapping: keyed)
        return KeyedDecodingContainer(container)
    }

    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        guard let value = self.container[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \"\(key.stringValue)\""
            ))
        }

        guard let unkeyed = value as? UnkeyedBox else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [Any].self, reality: value)
        }

        return _XMLUnkeyedDecodingContainer(referencing: decoder, wrapping: unkeyed)
    }

    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        let box: Box = container[key.stringValue] ?? NullBox()
        return _XMLDecoder(referencing: box, at: decoder.codingPath, options: decoder.options)
    }

    public func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: _XMLKey.super)
    }

    public func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}
