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
    private let container: SharedBox<UnkeyedBox>

    /// The path of coding keys taken to get to this point in encoding.
    public private(set) var codingPath: [CodingKey]

    /// The number of elements encoded into the container.
    public var count: Int {
        return container.withShared { $0.count }
    }

    // MARK: - Initialization

    /// Initializes `self` with the given references.
    init(referencing encoder: _XMLEncoder, codingPath: [CodingKey], wrapping container: SharedBox<UnkeyedBox>) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    // MARK: - UnkeyedEncodingContainer Methods

    public mutating func encodeNil() throws {
        container.withShared { container in
            container.append(encoder.box())
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
        try container.withShared { container in
            container.append(try encode(encoder, value))
        }
    }

    public mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        codingPath.append(_XMLKey(index: count))
        defer { self.codingPath.removeLast() }

        let sharedKeyed = SharedBox(KeyedBox())
        self.container.withShared { container in
            container.append(sharedKeyed)
        }

        let container = _XMLKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: sharedKeyed)
        return KeyedEncodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        codingPath.append(_XMLKey(index: count))
        defer { self.codingPath.removeLast() }

        let sharedUnkeyed = SharedBox(UnkeyedBox())
        container.withShared { container in
            container.append(sharedUnkeyed)
        }

        return _XMLUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: sharedUnkeyed)
    }

    public mutating func superEncoder() -> Encoder {
        return _XMLReferencingEncoder(referencing: encoder, at: count, wrapping: container)
    }
}
