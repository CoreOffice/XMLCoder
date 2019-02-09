//
//  KeyedBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 11/19/18.
//

import Foundation

struct KeyedStorage<Key: Hashable & Comparable, Value> {
    typealias Buffer = [Key: Value]

    fileprivate var buffer: Buffer = [:]

    var isEmpty: Bool {
        return buffer.isEmpty
    }

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
    func makeIterator() -> Buffer.Iterator {
        return buffer.makeIterator()
    }
}

extension KeyedStorage: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(Dictionary(uniqueKeysWithValues: elements))
    }
}

extension KeyedStorage: CustomStringConvertible {
    var description: String {
        return "\(buffer)"
    }
}

struct KeyedBox {
    typealias Key = String
    typealias Attribute = SimpleBox
    typealias Element = Box

    typealias Attributes = KeyedStorage<Key, Attribute>
    typealias Elements = KeyedStorage<Key, Element>

    var elements: Elements = [:]
    var attributes: Attributes = [:]

    func unbox() -> (elements: Elements, attributes: Attributes) {
        return (
            elements: elements,
            attributes: attributes
        )
    }
}

extension KeyedBox {
    init<E, A>(elements: E, attributes: A)
        where E: Sequence, E.Element == (Key, Element), A: Sequence, A.Element == (Key, Attribute) {
        let elements = Elements(Dictionary(uniqueKeysWithValues: elements))
        let attributes = Attributes(Dictionary(uniqueKeysWithValues: attributes))
        self.init(elements: elements, attributes: attributes)
    }

    init(elements: [Key: Element], attributes: [Key: Attribute]) {
        self.init(elements: Elements(elements), attributes: Attributes(attributes))
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

extension KeyedBox {
    var value: SimpleBox? {
        guard elements.count == 1, let value = elements["value"] as? SimpleBox ?? elements[""] as? SimpleBox, !value.isNull else { return nil }
        return value
    }
}

extension KeyedBox: CustomStringConvertible {
    var description: String {
        return "{attributes: \(attributes), elements: \(elements)}"
    }
}
