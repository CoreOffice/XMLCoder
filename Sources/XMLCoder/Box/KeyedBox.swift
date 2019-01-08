//
//  KeyedBox.swift
//  XMLCoderPackageDescription
//
//  Created by Vincent Esche on 11/19/18.
//

import Foundation

struct KeyedStorage<Key: Hashable & Comparable, Value> {
    typealias Buffer = [Key: Value]

    fileprivate var buffer: Buffer = [:]

    var count: Int {
        return buffer.count
    }

    var keys: Buffer.Keys {
        return buffer.keys
    }

    init(_ buffer: Buffer) {
        self.buffer = buffer
    }

    subscript(key: Key) -> Value? {
        get {
            return buffer[key]
        }
        set {
            buffer[key] = newValue
        }
    }

    func map<T>(_ transform: (Key, Value) throws -> T) rethrows -> [T] {
        return try buffer.map(transform)
    }

    func compactMap<T>(_ transform: ((Key, Value)) throws -> T?) rethrows -> [T] {
        return try buffer.compactMap(transform)
    }
}

extension KeyedStorage: Sequence {
    typealias Iterator = Buffer.Iterator

    func makeIterator() -> Iterator {
        return buffer.makeIterator()
    }
}

extension KeyedStorage: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(Dictionary(uniqueKeysWithValues: elements))
    }
}

extension KeyedStorage: CustomStringConvertible
    where Key: Comparable {
    var description: String {
        return "[\(buffer)]"
    }
}

class KeyedBox {
    typealias Key = String
    typealias Attribute = SimpleBox
    typealias Element = Box

    typealias Attributes = KeyedStorage<Key, Attribute>
    typealias Elements = KeyedStorage<Key, Element>

    var attributes: Attributes = [:]
    var elements: Elements = [:]

    init() {
        attributes = [:]
        elements = [:]
    }

    init<E, A>(elements: E, attributes: A)
        where E: Sequence, E.Element == (Key, Element), A: Sequence, A.Element == (Key, Attribute) {
        self.elements = Elements(Dictionary(uniqueKeysWithValues: elements))
        self.attributes = Attributes(Dictionary(uniqueKeysWithValues: attributes))
    }

    init(elements: [Key: Element], attributes: [Key: Attribute]) {
        self.elements = Elements(elements)
        self.attributes = Attributes(attributes)
    }

    func unbox() -> (elements: Elements, attributes: Attributes) {
        return (
            elements: elements,
            attributes: attributes
        )
    }
}

extension KeyedBox: Box {
    var isNull: Bool {
        return false
    }

    func xmlString() -> String? {
        return nil
    }
}

extension KeyedBox: CustomStringConvertible {
    var description: String {
        return "\(elements)"
    }
}
