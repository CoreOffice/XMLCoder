//
//  XMLReferencingEncoder.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/25/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

// MARK: - _XMLReferencingEncoder

/// _XMLReferencingEncoder is a special subclass of _XMLEncoder which has its own storage, but references the contents of a different encoder.
/// It's used in superEncoder(), which returns a new encoder for encoding a superclass -- the lifetime of the encoder should not escape the scope it's created in, but it doesn't necessarily know when it's done being used (to write to the original container).
internal class _XMLReferencingEncoder: _XMLEncoder {
    // MARK: Reference types.

    /// The type of container we're referencing.
    private enum Reference {
        /// Referencing a specific index in an unkeyed container.
        case unkeyed(UnkeyedBox, Int)

        /// Referencing a specific key in a dictionary container.
        case dictionary(DictionaryBox, String)
    }

    // MARK: - Properties

    /// The encoder we're referencing.
    internal let encoder: _XMLEncoder

    /// The container reference itself.
    private let reference: Reference

    // MARK: - Initialization

    /// Initializes `self` by referencing the given array container in the given encoder.
    internal init(
        referencing encoder: _XMLEncoder,
        at index: Int,
        wrapping unkeyed: UnkeyedBox
    ) {
        self.encoder = encoder
        reference = .unkeyed(unkeyed, index)
        super.init(
            options: encoder.options,
            nodeEncodings: encoder.nodeEncodings,
            codingPath: encoder.codingPath
        )

        codingPath.append(_XMLKey(index: index))
    }

    /// Initializes `self` by referencing the given dictionary container in the given encoder.
    internal init(
        referencing encoder: _XMLEncoder,
        key: CodingKey,
        convertedKey: CodingKey,
        wrapping dictionary: DictionaryBox
    ) {
        self.encoder = encoder
        reference = .dictionary(dictionary, convertedKey.stringValue)
        super.init(
            options: encoder.options,
            nodeEncodings: encoder.nodeEncodings,
            codingPath: encoder.codingPath
        )

        codingPath.append(key)
    }

    // MARK: - Coding Path Operations

    internal override var canEncodeNewValue: Bool {
        // With a regular encoder, the storage and coding path grow together.
        // A referencing encoder, however, inherits its parents coding path, as well as the key it was created for.
        // We have to take this into account.
        return storage.count == codingPath.count - encoder.codingPath.count - 1
    }

    // MARK: - Deinitialization

    // Finalizes `self` by writing the contents of our storage to the referenced encoder's storage.
    deinit {
        let box: Box
        switch self.storage.count {
        case 0: box = DictionaryBox()
        case 1: box = self.storage.popContainer()
        default: fatalError("Referencing encoder deallocated with multiple containers on stack.")
        }

        switch self.reference {
        case let .unkeyed(unkeyed, index):
            unkeyed.insert(box, at: index)
        case let .dictionary(dictionary, key):
            dictionary[key] = box
        }
    }
}
