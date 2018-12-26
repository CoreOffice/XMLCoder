//
//  XMLUnkeyedDecodingContainer.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/21/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

struct _XMLUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    // MARK: Properties

    /// A reference to the decoder we're reading from.
    private let decoder: _XMLDecoder

    /// A reference to the container we're reading from.
    private let container: UnkeyedBox

    /// The path of coding keys taken to get to this point in decoding.
    public private(set) var codingPath: [CodingKey]

    /// The index of the element we're about to decode.
    public private(set) var currentIndex: Int

    // MARK: - Initialization

    /// Initializes `self` by referencing the given decoder and container.
    init(referencing decoder: _XMLDecoder, wrapping container: UnkeyedBox) {
        self.decoder = decoder
        self.container = container
        codingPath = decoder.codingPath
        currentIndex = 0
    }

    // MARK: - UnkeyedDecodingContainer Methods

    public var count: Int? {
        return container.count
    }

    public var isAtEnd: Bool {
        return currentIndex >= count!
    }

    public mutating func decodeNil() throws -> Bool {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(
                codingPath: decoder.codingPath + [_XMLKey(index: self.currentIndex)],
                debugDescription: "Unkeyed container is at end."
            ))
        }

        if container[self.currentIndex].isNull {
            currentIndex += 1
            return true
        } else {
            return false
        }
    }

    public mutating func decode(_ type: Bool.Type) throws -> Bool {
        return try decode(type) { decoder, box in
            try decoder.unbox(box)
        }
    }

    public mutating func decode(_ type: Int.Type) throws -> Int {
        return try decodeSignedInteger(type)
    }

    public mutating func decode(_ type: Int8.Type) throws -> Int8 {
        return try decodeSignedInteger(type)
    }

    public mutating func decode(_ type: Int16.Type) throws -> Int16 {
        return try decodeSignedInteger(type)
    }

    public mutating func decode(_ type: Int32.Type) throws -> Int32 {
        return try decodeSignedInteger(type)
    }

    public mutating func decode(_ type: Int64.Type) throws -> Int64 {
        return try decodeSignedInteger(type)
    }

    public mutating func decode(_ type: UInt.Type) throws -> UInt {
        return try decodeUnsignedInteger(type)
    }

    public mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try decodeUnsignedInteger(type)
    }

    public mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try decodeUnsignedInteger(type)
    }

    public mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try decodeUnsignedInteger(type)
    }

    public mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try decodeUnsignedInteger(type)
    }

    public mutating func decode(_ type: Float.Type) throws -> Float {
        return try decodeFloatingPoint(type)
    }

    public mutating func decode(_ type: Double.Type) throws -> Double {
        return try decodeFloatingPoint(type)
    }

    public mutating func decode(_ type: String.Type) throws -> String {
        return try decode(type) { decoder, box in
            try decoder.unbox(box)
        }
    }

    public mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        return try decode(type) { decoder, box in
            try decoder.unbox(box)
        }
    }

    private mutating func decodeSignedInteger<T: BinaryInteger & SignedInteger & Decodable>(_ type: T.Type) throws -> T {
        return try decode(type) { decoder, box in
            try decoder.unbox(box)
        }
    }

    private mutating func decodeUnsignedInteger<T: BinaryInteger & UnsignedInteger & Decodable>(_ type: T.Type) throws -> T {
        return try decode(type) { decoder, box in
            try decoder.unbox(box)
        }
    }

    private mutating func decodeFloatingPoint<T: BinaryFloatingPoint & Decodable>(_ type: T.Type) throws -> T {
        return try decode(type) { decoder, box in
            try decoder.unbox(box)
        }
    }

    private mutating func decode<T: Decodable>(
        _ type: T.Type,
        decode: (_XMLDecoder, Box) throws -> T?
    ) throws -> T {
        guard let strategy = self.decoder.nodeDecodings.last else {
            preconditionFailure("Attempt to access node decoding strategy from empty stack.")
        }
        decoder.codingPath.append(_XMLKey(index: currentIndex))
        let nodeDecodings = decoder.options.nodeDecodingStrategy.nodeDecodings(
            forType: T.self,
            with: decoder
        )
        decoder.nodeDecodings.append(nodeDecodings)
        defer {
            _ = decoder.nodeDecodings.removeLast()
            _ = decoder.codingPath.removeLast()
        }
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(
                codingPath: decoder.codingPath + [_XMLKey(index: self.currentIndex)],
                debugDescription: "Unkeyed container is at end."
            ))
        }
        let box = container[self.currentIndex]
        let value = try decode(decoder, box)
        guard let decoded: T = value else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(
                codingPath: decoder.codingPath + [_XMLKey(index: self.currentIndex)],
                debugDescription: "Expected \(type) but found null instead."
            ))
        }
        currentIndex += 1
        return decoded
    }

    public mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> {
        decoder.codingPath.append(_XMLKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !isAtEnd else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."
            ))
        }

        let value = self.container[self.currentIndex]
        guard !value.isNull else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get keyed decoding container -- found null value instead."
            ))
        }

        guard let keyed = value as? KeyedBox else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [String: Any].self, reality: value)
        }

        currentIndex += 1
        let container = _XMLKeyedDecodingContainer<NestedKey>(referencing: decoder, wrapping: keyed)
        return KeyedDecodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        decoder.codingPath.append(_XMLKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !isAtEnd else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."
            ))
        }

        let value = container[self.currentIndex]
        guard !value.isNull else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get keyed decoding container -- found null value instead."
            ))
        }

        guard let unkeyed = value as? UnkeyedBox else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: UnkeyedBox.self, reality: value)
        }

        currentIndex += 1
        return _XMLUnkeyedDecodingContainer(referencing: decoder, wrapping: unkeyed)
    }

    public mutating func superDecoder() throws -> Decoder {
        decoder.codingPath.append(_XMLKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Decoder.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get superDecoder() -- unkeyed container is at end."
            ))
        }

        let value = container[self.currentIndex]
        currentIndex += 1
        return _XMLDecoder(
            referencing: value,
            options: decoder.options,
            nodeDecodings: decoder.nodeDecodings,
            codingPath: decoder.codingPath
        )
    }
}
