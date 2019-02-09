//
//  XMLUnkeyedDecodingContainer.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/21/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

struct XMLUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    typealias KeyedContainer = SharedBox<KeyedBox>
    typealias UnkeyedContainer = SharedBox<UnkeyedBox>

    // MARK: Properties

    /// A reference to the decoder we're reading from.
    private let decoder: XMLDecoderImplementation

    /// A reference to the container we're reading from.
    private let container: UnkeyedContainer

    /// The path of coding keys taken to get to this point in decoding.
    public private(set) var codingPath: [CodingKey]

    /// The index of the element we're about to decode.
    public private(set) var currentIndex: Int

    // MARK: - Initialization

    /// Initializes `self` by referencing the given decoder and container.
    init(referencing decoder: XMLDecoderImplementation, wrapping container: UnkeyedContainer) {
        self.decoder = decoder
        self.container = container
        codingPath = decoder.codingPath
        currentIndex = 0
    }

    // MARK: - UnkeyedDecodingContainer Methods

    public var count: Int? {
        return container.withShared { unkeyedBox in
            unkeyedBox.count
        }
    }

    public var isAtEnd: Bool {
        return currentIndex >= count!
    }

    public mutating func decodeNil() throws -> Bool {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(
                codingPath: decoder.codingPath + [XMLKey(index: self.currentIndex)],
                debugDescription: "Unkeyed container is at end."
            ))
        }

        let isNull = container.withShared { unkeyedBox in
            unkeyedBox[self.currentIndex].isNull
        }

        if isNull {
            currentIndex += 1
            return true
        } else {
            return false
        }
    }

    public mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
        return try decode(type) { decoder, box in
            try decoder.unbox(box)
        }
    }

    private mutating func decode<T: Decodable>(
        _ type: T.Type,
        decode: (XMLDecoderImplementation, Box) throws -> T?
    ) throws -> T {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(
                codingPath: decoder.codingPath + [XMLKey(index: self.currentIndex)],
                debugDescription: "Unkeyed container is at end."
            ))
        }

        decoder.codingPath.append(XMLKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        let box: Box

        // work around unkeyed box wrapped as single element of keyed box
        if let type = type as? AnyArray.Type,
            let keyedBox = container
            .withShared({ $0[self.currentIndex] as? KeyedBox }),
            keyedBox.attributes.isEmpty,
            keyedBox.elements.count == 1,
            let firstKey = keyedBox.elements.keys.first,
            let unkeyedBox = keyedBox.elements[firstKey] {
            box = unkeyedBox
        } else {
            box = container.withShared { unkeyedBox in
                unkeyedBox[self.currentIndex]
            }
        }

        let value = try decode(decoder, box)

        defer { currentIndex += 1 }

        if value == nil, let type = type as? AnyOptional.Type,
            let result = type.init() as? T {
            return result
        }

        guard let decoded: T = value else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(
                codingPath: decoder.codingPath + [XMLKey(index: self.currentIndex)],
                debugDescription: "Expected \(type) but found null instead."
            ))
        }

        return decoded
    }

    public mutating func nestedContainer<NestedKey>(
        keyedBy _: NestedKey.Type
    ) throws -> KeyedDecodingContainer<NestedKey> {
        decoder.codingPath.append(XMLKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !isAtEnd else {
            throw DecodingError.valueNotFound(
                KeyedDecodingContainer<NestedKey>.self, DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."
                )
            )
        }

        let value = self.container.withShared { unkeyedBox in
            unkeyedBox[self.currentIndex]
        }
        guard !value.isNull else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<NestedKey>.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get keyed decoding container -- found null value instead."
            ))
        }

        guard let keyedContainer = value as? KeyedContainer else {
            throw DecodingError._typeMismatch(at: codingPath,
                                              expectation: [String: Any].self,
                                              reality: value)
        }

        currentIndex += 1
        let container = XMLKeyedDecodingContainer<NestedKey>(
            referencing: decoder,
            wrapping: keyedContainer
        )
        return KeyedDecodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        decoder.codingPath.append(XMLKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !isAtEnd else {
            throw DecodingError.valueNotFound(
                UnkeyedDecodingContainer.self, DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Cannot get nested keyed container -- unkeyed container is at end."
                )
            )
        }

        let value = container.withShared { unkeyedBox in
            unkeyedBox[self.currentIndex]
        }
        guard !value.isNull else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get keyed decoding container -- found null value instead."
            ))
        }

        guard let unkeyedContainer = value as? UnkeyedContainer else {
            throw DecodingError._typeMismatch(at: codingPath,
                                              expectation: UnkeyedBox.self,
                                              reality: value)
        }

        currentIndex += 1
        return XMLUnkeyedDecodingContainer(referencing: decoder, wrapping: unkeyedContainer)
    }

    public mutating func superDecoder() throws -> Decoder {
        decoder.codingPath.append(XMLKey(index: currentIndex))
        defer { self.decoder.codingPath.removeLast() }

        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Decoder.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get superDecoder() -- unkeyed container is at end."
            ))
        }

        let value = container.withShared { unkeyedBox in
            unkeyedBox[self.currentIndex]
        }
        currentIndex += 1
        return XMLDecoderImplementation(referencing: value,
                                        at: decoder.codingPath,
                                        options: decoder.options)
    }
}
