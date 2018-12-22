//
//  XMLKeyedEncodingContainer.swift
//  XMLCoder
//
//  Created by Vincent Esche on 11/20/18.
//

import Foundation

struct _XMLKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K

    // MARK: Properties

    /// A reference to the encoder we're writing to.
    private let encoder: _XMLEncoder

    /// A reference to the container we're writing to.
    private let container: KeyedBox

    /// The path of coding keys taken to get to this point in encoding.
    public private(set) var codingPath: [CodingKey]

    // MARK: - Initialization

    /// Initializes `self` with the given references.
    init(referencing encoder: _XMLEncoder, codingPath: [CodingKey], wrapping container: KeyedBox) {
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
        case let .custom(converter):
            return converter(codingPath + [key])
        }
    }

    // MARK: - KeyedEncodingContainerProtocol Methods

    public mutating func encodeNil(forKey key: Key) throws {
        container.elements[_converted(key).stringValue] = NullBox()
    }

    public mutating func encode(_ value: Bool, forKey key: Key) throws {
        return try encode(value, forKey: key) { encoder, value in
            encoder.box(value)
        }
    }

    public mutating func encode(_ value: Decimal, forKey key: Key) throws {
        return try encode(value, forKey: key) { encoder, value in
            encoder.box(value)
        }
    }

    public mutating func encode(_ value: Int, forKey key: Key) throws {
        return try encodeSignedInteger(value, forKey: key)
    }

    public mutating func encode(_ value: Int8, forKey key: Key) throws {
        return try encodeSignedInteger(value, forKey: key)
    }

    public mutating func encode(_ value: Int16, forKey key: Key) throws {
        return try encodeSignedInteger(value, forKey: key)
    }

    public mutating func encode(_ value: Int32, forKey key: Key) throws {
        return try encodeSignedInteger(value, forKey: key)
    }

    public mutating func encode(_ value: Int64, forKey key: Key) throws {
        return try encodeSignedInteger(value, forKey: key)
    }

    public mutating func encode(_ value: UInt, forKey key: Key) throws {
        return try encodeUnsignedInteger(value, forKey: key)
    }

    public mutating func encode(_ value: UInt8, forKey key: Key) throws {
        return try encodeUnsignedInteger(value, forKey: key)
    }

    public mutating func encode(_ value: UInt16, forKey key: Key) throws {
        return try encodeUnsignedInteger(value, forKey: key)
    }

    public mutating func encode(_ value: UInt32, forKey key: Key) throws {
        return try encodeUnsignedInteger(value, forKey: key)
    }

    public mutating func encode(_ value: UInt64, forKey key: Key) throws {
        return try encodeUnsignedInteger(value, forKey: key)
    }

    public mutating func encode(_ value: Float, forKey key: Key) throws {
        return try encodeFloatingPoint(value, forKey: key)
    }

    public mutating func encode(_ value: Double, forKey key: Key) throws {
        return try encodeFloatingPoint(value, forKey: key)
    }

    public mutating func encode(_ value: String, forKey key: Key) throws {
        return try encode(value, forKey: key) { encoder, value in
            encoder.box(value)
        }
    }

    public mutating func encode(_ value: Date, forKey key: Key) throws {
        return try encode(value, forKey: key) { encoder, value in
            try encoder.box(value)
        }
    }

    public mutating func encode(_ value: Data, forKey key: Key) throws {
        return try encode(value, forKey: key) { encoder, value in
            try encoder.box(value)
        }
    }

    public mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        return try encode(value, forKey: key) { encoder, value in
            try encoder.box(value)
        }
    }

    private mutating func encodeSignedInteger<T: BinaryInteger & SignedInteger & Encodable>(_ value: T, forKey key: Key) throws {
        return try encode(value, forKey: key) { encoder, value in
            encoder.box(value)
        }
    }

    private mutating func encodeUnsignedInteger<T: BinaryInteger & UnsignedInteger & Encodable>(_ value: T, forKey key: Key) throws {
        return try encode(value, forKey: key) { encoder, value in
            encoder.box(value)
        }
    }

    private mutating func encodeFloatingPoint<T: BinaryFloatingPoint & Encodable>(_ value: T, forKey key: Key) throws {
        return try encode(value, forKey: key) { encoder, value in
            try encoder.box(value)
        }
    }

    private mutating func encode<T: Encodable>(
        _ value: T,
        forKey key: Key,
        encode: (_XMLEncoder, T) throws -> Box
    ) throws {
        defer {
            _ = self.encoder.nodeEncodings.removeLast()
            self.encoder.codingPath.removeLast()
        }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        encoder.codingPath.append(key)
        let nodeEncodings = encoder.options.nodeEncodingStrategy.nodeEncodings(
            forType: T.self,
            with: encoder
        )
        encoder.nodeEncodings.append(nodeEncodings)
        let box = try encode(encoder, value)
        switch strategy(key) {
        case .attribute:
            guard let attribute = box as? SimpleBox else {
                throw EncodingError.invalidValue(value, EncodingError.Context(
                    codingPath: [],
                    debugDescription: "Complex values cannot be encoded as attributes."
                ))
            }
            container.attributes[_converted(key).stringValue] = attribute
        case .element:
            container.elements[_converted(key).stringValue] = box
        }
    }

    public mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let keyed = KeyedBox()
        self.container.elements[_converted(key).stringValue] = keyed

        codingPath.append(key)
        defer { self.codingPath.removeLast() }

        let container = _XMLKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: keyed)
        return KeyedEncodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let unkeyed = UnkeyedBox()
        container.elements[_converted(key).stringValue] = unkeyed

        codingPath.append(key)
        defer { self.codingPath.removeLast() }
        return _XMLUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: unkeyed)
    }

    public mutating func superEncoder() -> Encoder {
        return _XMLReferencingEncoder(referencing: encoder, key: _XMLKey.super, convertedKey: _converted(_XMLKey.super), wrapping: container)
    }

    public mutating func superEncoder(forKey key: Key) -> Encoder {
        return _XMLReferencingEncoder(referencing: encoder, key: key, convertedKey: _converted(key), wrapping: container)
    }
}
