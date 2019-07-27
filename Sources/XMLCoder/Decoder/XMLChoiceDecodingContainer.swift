//
//  XMLChoiceDecodingContainer.swift
//  XMLCoder
//
//  Created by James Bean on 7/18/19.
//

import Foundation

struct XMLChoiceDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K

    // MARK: Properties

    /// A reference to the decoder we're reading from.
    private let decoder: XMLDecoderImplementation

    /// A reference to the container we're reading from.
    private let container: SharedBox<ChoiceBox>

    /// The path of coding keys taken to get to this point in decoding.
    public private(set) var codingPath: [CodingKey]

    // MARK: - Initialization

    /// Initializes `self` by referencing the given decoder and container.
    init(referencing decoder: XMLDecoderImplementation, wrapping container: SharedBox<ChoiceBox>) {
        self.decoder = decoder

        func mapKeys(
            _ container: SharedBox<ChoiceBox>, closure: (String) -> String
        ) -> SharedBox<ChoiceBox> {
            return SharedBox(
                ChoiceBox(
                    key: closure(container.withShared { $0.key }),
                    element: container.withShared { $0.element }
                )
            )
        }
        // FIXME: Keep DRY from XMLKeyedDecodingContainer.init
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
        case .convertFromKebabCase:
            self.container = mapKeys(container) { key in
                XMLDecoder.KeyDecodingStrategy._convertFromKebabCase(key)
            }
        case .convertFromCapitalized:
            self.container = mapKeys(container) { key in
                XMLDecoder.KeyDecodingStrategy._convertFromCapitalized(key)
            }
        case let .custom(converter):
            self.container = mapKeys(container) { key in
                let codingPath = decoder.codingPath + [
                    XMLKey(stringValue: key, intValue: nil),
                ]
                return converter(codingPath).stringValue
            }
        }
        codingPath = decoder.codingPath
    }

    // MARK: - KeyedDecodingContainerProtocol Methods

    public var allKeys: [Key] {
        return container.withShared { Key(stringValue: $0.key) }.map { [$0] } ?? []
    }

    public func contains(_ key: Key) -> Bool {
        return container.withShared { $0.key == key.stringValue }
    }

    public func decodeNil(forKey key: Key) throws -> Bool {
        return container.withShared { $0.element.isNull }
    }

    public func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        guard container.withShared({ $0.key == key.stringValue }) else {
            throw DecodingError.typeMismatch(
                at: codingPath,
                expectation: type,
                reality: container
            )
        }
        return try decodeConcrete(type, forKey: key)
    }

    public func nestedContainer<NestedKey>(
        keyedBy _: NestedKey.Type, forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }

        let value = container.withShared { $0.element }
        let container: XMLKeyedDecodingContainer<NestedKey>

        if let keyedContainer = value as? SharedBox<KeyedBox> {
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
            throw DecodingError.typeMismatch(
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
        guard let unkeyedElement = container.withShared({ $0.element }) as? UnkeyedBox else {
            throw DecodingError.typeMismatch(
                at: codingPath,
                expectation: UnkeyedBox.self,
                reality: container
            )
        }
        return XMLUnkeyedDecodingContainer(
            referencing: decoder,
            wrapping: SharedBox(unkeyedElement)
        )
    }

    public func superDecoder() throws -> Decoder {
        return try _superDecoder(forKey: XMLKey.super)
    }

    public func superDecoder(forKey key: Key) throws -> Decoder {
        return try _superDecoder(forKey: key)
    }
}

/// Private functions
extension XMLChoiceDecodingContainer {
    private func _errorDescription(of key: CodingKey) -> String {
        switch decoder.options.keyDecodingStrategy {
        case .convertFromSnakeCase:
            // In this case we can attempt to recover the original value by
            // reversing the transform
            let original = key.stringValue
            let converted = XMLEncoder.KeyEncodingStrategy
                ._convertToSnakeCase(original)
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
        guard let strategy = self.decoder.nodeDecodings.last else {
            preconditionFailure(
                """
                Attempt to access node decoding strategy from empty stack.
                """
            )
        }
        let elements = container
            .withShared { singleElementBox -> [KeyedBox.Element] in
                if let unkeyed = singleElementBox.element as? UnkeyedBox {
                    return unkeyed
                } else if let keyed = singleElementBox.element as? KeyedBox {
                    return keyed.elements[key.stringValue]
                } else {
                    return []
                }
            }
        decoder.codingPath.append(key)
        let nodeDecodings = decoder.options.nodeDecodingStrategy.nodeDecodings(
            forType: T.self,
            with: decoder
        )
        decoder.nodeDecodings.append(nodeDecodings)
        defer {
            _ = decoder.nodeDecodings.removeLast()
            decoder.codingPath.removeLast()
        }
        let box: Box = elements
        let value: T?
        if !(type is AnySequence.Type), let unkeyedBox = box as? UnkeyedBox,
            let first = unkeyedBox.first {
            value = try decoder.unbox(first)
        } else {
            value = try decoder.unbox(box)
        }

        if value == nil, let type = type as? AnyOptional.Type,
            let result = type.init() as? T {
            return result
        }

        guard let unwrapped = value else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription:
                "Expected \(type) value but found null instead."
            ))
        }
        return unwrapped
    }

    private func _superDecoder(forKey key: CodingKey) throws -> Decoder {
        decoder.codingPath.append(key)
        defer { decoder.codingPath.removeLast() }
        let box: Box = container.withShared { $0.element }
        return XMLDecoderImplementation(
            referencing: box,
            options: decoder.options,
            nodeDecodings: decoder.nodeDecodings,
            codingPath: decoder.codingPath
        )
    }
}
