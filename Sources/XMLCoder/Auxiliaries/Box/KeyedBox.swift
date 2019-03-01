//
//  KeyedBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 11/19/18.
//

import Foundation

struct KeyedStorage<Key: Hashable & Comparable, Value> {
    struct Iterator: IteratorProtocol {
        fileprivate var orderIterator: Order.Iterator
        fileprivate var buffer: Buffer
        mutating func next() -> (Key, Value)? {
            guard
                let key = orderIterator.next(),
                let value = buffer[key]
            else { return nil }

            return (key, value)
        }
    }

    typealias Buffer = [Key: Value]
    typealias Order = [Key]

    fileprivate var order = Order()
    fileprivate var buffer = Buffer()

    var isEmpty: Bool {
        return buffer.isEmpty
    }

    var count: Int {
        return buffer.count
    }

    var keys: Buffer.Keys {
        return buffer.keys
    }

    init<S>(_ sequence: S) where S: Sequence, S.Element == (Key, Value) {
        order = sequence.map { $0.0 }
        buffer = Dictionary(uniqueKeysWithValues: sequence)
    }

    subscript(key: Key) -> Value? {
        get {
            return buffer[key]
        }
        set {
            if buffer[key] == nil {
                order.append(key)
            }
            buffer[key] = newValue
        }
    }

    func map<T>(_ transform: (Key, Value) throws -> T) rethrows -> [T] {
        return try buffer.map(transform)
    }

    func compactMap<T>(_ transform: ((Key, Value)) throws -> T?) rethrows -> [T] {
        return try buffer.compactMap(transform)
    }

    init() {}
}

extension KeyedStorage: Sequence {
    func makeIterator() -> Iterator {
        return Iterator(orderIterator: order.makeIterator(), buffer: buffer)
    }
}

extension KeyedStorage: CustomStringConvertible {
    var description: String {
        let result = order.compactMap { (key: Key) -> String? in
            guard let value = buffer[key] else { return nil }

            return "\"\(key)\": \(value)"
        }.joined(separator: ", ")

        return "[\(result)]"
    }
}

struct KeyedBox {
    typealias Key = String
    typealias Attribute = SimpleBox
    typealias Element = Box

    typealias Attributes = KeyedStorage<Key, Attribute>
    typealias Elements = KeyedStorage<Key, Element>

    var elements = Elements()
    var attributes = Attributes()

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
        let elements = Elements(elements)
        let attributes = Attributes(attributes)
        self.init(elements: elements, attributes: attributes)
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
        guard
            elements.count == 1,
            let value = elements["value"] as? SimpleBox
            ?? elements[""] as? SimpleBox,
            !value.isNull else { return nil }
        return value
    }
}

extension KeyedBox: CustomStringConvertible {
    var description: String {
        return "{attributes: \(attributes), elements: \(elements)}"
    }
}
