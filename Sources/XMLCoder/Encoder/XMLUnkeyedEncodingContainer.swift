//
//  XMLUnkeyedEncodingContainer.swift
//  XMLCoder
//
//  Created by Vincent Esche on 11/20/18.
//

import Foundation

struct _XMLUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    // MARK: Properties

    /// A reference to the encoder we're writing to.
    private let encoder: _XMLEncoder

    /// A reference to the container we're writing to.
    private let container: UnkeyedBox

    /// The path of coding keys taken to get to this point in encoding.
    public private(set) var codingPath: [CodingKey]

    /// The number of elements encoded into the container.
    public var count: Int {
        return container.count
    }

    // MARK: - Initialization

    /// Initializes `self` with the given references.
    init(referencing encoder: _XMLEncoder, codingPath: [CodingKey], wrapping container: UnkeyedBox) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    // MARK: - UnkeyedEncodingContainer Methods

    public mutating func encodeNil() throws {
        container.append(encoder.box())
    }

    public mutating func encode(_ value: Bool) throws {
        encode(value) { encoder, value in
            encoder.box(value)
        }
    }

    public mutating func encode(_ value: Decimal) throws {
        encode(value) { encoder, value in
            encoder.box(value)
        }
    }

    public mutating func encode(_ value: Int) throws {
        try encodeSignedInteger(value)
    }

    public mutating func encode(_ value: Int8) throws {
        try encodeSignedInteger(value)
    }

    public mutating func encode(_ value: Int16) throws {
        try encodeSignedInteger(value)
    }

    public mutating func encode(_ value: Int32) throws {
        try encodeSignedInteger(value)
    }

    public mutating func encode(_ value: Int64) throws {
        try encodeSignedInteger(value)
    }

    public mutating func encode(_ value: UInt) throws {
        try encodeUnsignedInteger(value)
    }

    public mutating func encode(_ value: UInt8) throws {
        try encodeUnsignedInteger(value)
    }

    public mutating func encode(_ value: UInt16) throws {
        try encodeUnsignedInteger(value)
    }

    public mutating func encode(_ value: UInt32) throws {
        try encodeUnsignedInteger(value)
    }

    public mutating func encode(_ value: UInt64) throws {
        try encodeUnsignedInteger(value)
    }

    public mutating func encode(_ value: Float) throws {
        try encodeFloatingPoint(value)
    }

    public mutating func encode(_ value: Double) throws {
        try encodeFloatingPoint(value)
    }

    public mutating func encode(_ value: String) throws {
        encode(value) { encoder, value in
            encoder.box(value)
        }
    }

    public mutating func encode(_ value: Date) throws {
        try encode(value) { encoder, value in
            return try encoder.box(value)
        }
    }

    public mutating func encode(_ value: Data) throws {
        try encode(value) { encoder, value in
            return try encoder.box(value)
        }
    }

    private mutating func encodeSignedInteger<T: BinaryInteger & SignedInteger & Encodable>(_ value: T) throws {
        encode(value) { encoder, value in
            encoder.box(value)
        }
    }

    private mutating func encodeUnsignedInteger<T: BinaryInteger & UnsignedInteger & Encodable>(_ value: T) throws {
        encode(value) { encoder, value in
            encoder.box(value)
        }
    }

    private mutating func encodeFloatingPoint<T: BinaryFloatingPoint & Encodable>(_ value: T) throws {
        try encode(value) { encoder, value in
            return try encoder.box(value)
        }
    }

    public mutating func encode<T: Encodable>(_ value: T) throws {
        try encode(value) { encoder, value in
            return try encoder.box(value)
        }
    }

    private mutating func encode<T: Encodable>(
        _ value: T,
        encode: (_XMLEncoder, T) throws -> Box
    ) rethrows {
        encoder.codingPath.append(_XMLKey(index: count))
        defer { self.encoder.codingPath.removeLast() }
        container.append(try encode(encoder, value))
    }

    public mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        codingPath.append(_XMLKey(index: count))
        defer { self.codingPath.removeLast() }

        let keyed = KeyedBox()
        self.container.append(keyed)

        let container = _XMLKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: keyed)
        return KeyedEncodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        codingPath.append(_XMLKey(index: count))
        defer { self.codingPath.removeLast() }

        let unkeyed = UnkeyedBox()
        container.append(unkeyed)

        return _XMLUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: unkeyed)
    }

    public mutating func superEncoder() -> Encoder {
        return _XMLReferencingEncoder(referencing: encoder, at: container.count, wrapping: container)
    }
}
