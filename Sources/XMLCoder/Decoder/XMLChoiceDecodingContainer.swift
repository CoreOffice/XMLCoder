//
//  XMLChoiceDecodingContainer.swift
//  XMLCoder
//
//  Created by James Bean on 7/18/19.
//

/// Container specialized for decoding XML choice elements.
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
        return container.withShared { [Key(stringValue: $0.key)!] }
    }

    public func contains(_ key: Key) -> Bool {
        return container.withShared { $0.key == key.stringValue }
    }

    public func decodeNil(forKey key: Key) throws -> Bool {
        return container.withShared { $0.element.isNull }
    }

    public func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        guard container.withShared({ $0.key == key.stringValue }), key is XMLChoiceCodingKey else {
            throw DecodingError.typeMismatch(
                at: codingPath,
                expectation: type,
                reality: container
            )
        }
        return try decoder.unbox(container.withShared { $0.element })
    }

    public func nestedContainer<NestedKey>(
        keyedBy _: NestedKey.Type, forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> {
        fatalError("Choice elements cannot produce a nested container.")
    }

    public func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        fatalError("Choice elements cannot produce a unkeyed nested container.")
    }

    public func superDecoder() throws -> Decoder {
        fatalError("XMLChoiceDecodingContainer cannot produce a super decoder.")
    }

    public func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError("XMLChoiceDecodingContainer cannot produce a super decoder.")
    }
}
