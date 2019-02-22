//
//  XMLKeyedDecodingContainer.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/21/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

// MARK: Decoding Containers

struct XMLKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K
    typealias KeyedContainer = SharedBox<KeyedBox>
    typealias UnkeyedContainer = SharedBox<UnkeyedBox>

    // MARK: Properties

    /// A reference to the decoder we're reading from.
    private let decoder: XMLDecoderImplementation

    /// A reference to the container we're reading from.
    private let container: KeyedContainer

    /// The path of coding keys taken to get to this point in decoding.
    public private(set) var codingPath: [CodingKey]

    // MARK: - Initialization

    /// Initializes `self` by referencing the given decoder and container.
    init(referencing decoder: XMLDecoderImplementation, wrapping container: KeyedContainer) {
        self.decoder = decoder

        func mapKeys(_ container: KeyedContainer, closure: (String) -> String) -> KeyedContainer {
            let attributes = container.withShared { keyedBox in
                keyedBox.attributes.map { (closure($0), $1) }
            }
            let elements = container.withShared { keyedBox in
                keyedBox.elements.map { (closure($0), $1) }
            }
            let keyedBox = KeyedBox(elements: elements, attributes: attributes)
            return SharedBox(keyedBox)
        }

        switch decoder.options.keyDecodingStrategy {
        case .useDefaultKeys:
            self.container = container
        case .convertFromSnakeCase:
            // Convert the snake case keys in the container to camel case.
            // If we hit a duplicate key after conversion, then we'll use the
            // first one we saw. Effectively an undefined behavior with dictionaries.
            self.container = mapKeys(container) { key in
                XMLDecoder.KeyDecodingStrategy._convertFromSnakeCase(key)
            }
        case .convertFromCapitalized:
            self.container = mapKeys(container) { key in
                XMLDecoder.KeyDecodingStrategy._convertFromCapitalized(key)
            }
        case let .custom(converter):
            self.container = mapKeys(container) { key in
                let codingPath = decoder.codingPath + [XMLKey(stringValue: key, intValue: nil)]
                return converter(codingPath).stringValue
            }
        }
        codingPath = decoder.codingPath
    }

    // MARK: - KeyedDecodingContainerProtocol Methods

    public var allKeys: [Key] {
        let elementKeys = container.withShared { keyedBox in
            keyedBox.elements.keys.compactMap { Key(stringValue: $0) }
        }

        let attributeKeys = container.withShared { keyedBox in
            keyedBox.attributes.keys.compactMap { Key(stringValue: $0) }
        }

        return attributeKeys + elementKeys
    }

    public func contains(_ key: Key) -> Bool {
        let elementOrNil = container.withShared { keyedBox in
            keyedBox.elements[key.stringValue]
        }

        let attributeOrNil = container.withShared { keyedBox in
            keyedBox.attributes[key.stringValue]
        }

        return (elementOrNil ?? attributeOrNil) != nil
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
        let elementOrNil = container.withShared { keyedBox in
            keyedBox.elements[key.stringValue]
        }

        let attributeOrNil = container.withShared { keyedBox in
            keyedBox.attributes[key.stringValue]
        }

        let box = elementOrNil ?? attributeOrNil

        return box?.isNull ?? true
    }

    public func decode<T: Decodable>(
        _ type: T.Type, forKey key: Key
    ) throws -> T {
        let attributeFound = container.withShared { keyedBox in
            keyedBox.attributes[key.stringValue] != nil
        }

        let elementFound = container.withShared { keyedBox in
            keyedBox.elements[key.stringValue] != nil || keyedBox.value != nil
        }

        if let type = type as? AnyEmptySequence.Type,
            !attributeFound,
            !elementFound,
            let result = type.init() as? T {
            return result
        }

        return try decodeConcrete(type, forKey: key)
    }

    private func decodeSignedInteger<T>(_ type: T.Type,
                                        forKey key: Key) throws -> T
        where T: BinaryInteger & SignedInteger & Decodable {
        return try decodeConcrete(type, forKey: key)
    }

    private func decodeUnsignedInteger<T>(_ type: T.Type,
                                          forKey key: Key) throws -> T
        where T: BinaryInteger & UnsignedInteger & Decodable {
        return try decodeConcrete(type, forKey: key)
    }

    private func decodeFloatingPoint<T>(_ type: T.Type,
                                        forKey key: Key) throws -> T
        where T: BinaryFloatingPoint & Decodable {
        return try decodeConcrete(type, forKey: key)
    }

    private func decodeConcrete<T: Decodable>(
        _ type: T.Type,
        forKey key: Key
    ) throws -> T {
        let elementOrNil = container.withShared { keyedBox -> KeyedBox.Element? in
            if ["value", ""].contains(key.stringValue) {
                return keyedBox.elements[key.stringValue] ?? keyedBox.value
            } else {
                return keyedBox.elements[key.stringValue]
            }
        }

        let attributeOrNil = container.withShared { keyedBox in
            keyedBox.attributes[key.stringValue]
        }

        guard let entry = elementOrNil ?? attributeOrNil else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "No value associated with key \(_errorDescription(of: key))."
            ))
        }

        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        let value: T? = try decoder.unbox(entry)

        if value == nil {
            if let type = type as? AnyArray.Type,
                type.elementType is AnyOptional.Type,
                let result = [nil] as? T {
                return result
            } else if let type = type as? AnyOptional.Type,
                let result = type.init() as? T {
                return result
            }
        }

        guard let unwrapped = value else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected \(type) value but found null instead."
            ))
        }

        return unwrapped
    }

    public func nestedContainer<NestedKey>(
        keyedBy _: NestedKey.Type, forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        let elementOrNil = self.container.withShared { keyedBox in
            keyedBox.elements[key.stringValue]
        }

        let attributeOrNil = self.container.withShared { keyedBox in
            keyedBox.attributes[key.stringValue]
        }

        guard let value = elementOrNil ?? attributeOrNil else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get \(KeyedDecodingContainer<NestedKey>.self) -- no value found for key \"\(key.stringValue)\""
            ))
        }

        let container: XMLKeyedDecodingContainer<NestedKey>
        if let keyedContainer = value as? KeyedContainer {
            container = XMLKeyedDecodingContainer<NestedKey>(
                referencing: decoder,
                wrapping: keyedContainer
            )
        } else if let keyedContainer = value as? KeyedBox {
            container = XMLKeyedDecodingContainer<NestedKey>(
                referencing: decoder,
                wrapping: SharedBox(keyedContainer)
            )
        } else {
            throw DecodingError._typeMismatch(
                at: codingPath,
                expectation: [String: Any].self,
                reality: value
            )
        }

        return KeyedDecodingContainer(container)
    }

    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        let elementOrNil = container.withShared { keyedBox in
            keyedBox.elements[key.stringValue]
        }

        let attributeOrNil = container.withShared { keyedBox in
            keyedBox.attributes[key.stringValue]
        }

        guard let value = elementOrNil ?? attributeOrNil else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get UnkeyedDecodingContainer -- no value found for key \"\(key.stringValue)\""
            ))
        }

        if let unkeyedContainer = value as? UnkeyedContainer {
            return XMLUnkeyedDecodingContainer(referencing: decoder, wrapping: unkeyedContainer)
        } else if let unkeyedContainer = value as? UnkeyedBox {
            return XMLUnkeyedDecodingContainer(referencing: decoder, wrapping: SharedBox(unkeyedContainer))
        } else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [Any].self, reality: value)
        }
    }

    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        let elementOrNil = container.withShared { keyedBox in
            keyedBox.elements[key.stringValue]
        }

        let attributeOrNil = container.withShared { keyedBox in
            keyedBox.attributes[key.stringValue]
        }

        let box: Box = elementOrNil ?? attributeOrNil ?? NullBox()
        return XMLDecoderImplementation(referencing: box, at: decoder.codingPath, options: decoder.options)
    }

    public func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: XMLKey.super)
    }

    public func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}
