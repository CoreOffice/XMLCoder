//
//  KeyedBox.swift
//  XMLCoderPackageDescription
//
//  Created by Vincent Esche on 11/19/18.
//

import Foundation

struct KeyedStorage<Key: Hashable, Value> {
    typealias Buffer = [Key: Value]
    
    fileprivate var buffer: Buffer = [:]
    
    var count: Int {
        return self.buffer.count
    }
    
    var keys: Buffer.Keys {
        return self.buffer.keys
    }
    
    init(_ buffer: Buffer) {
        self.buffer = buffer
    }
    
    subscript(key: Key) -> Value? {
        get {
            return self.buffer[key]
        }
        set {
            self.buffer[key] = newValue
        }
    }
    
    func filter(_ isIncluded: (Key, Value) throws -> Bool) rethrows -> [(Key, Value)] {
        return try self.buffer.filter(isIncluded)
    }
    
    func map<T>(_ transform: (Key, Value) throws -> T) rethrows -> [T] {
        return try self.buffer.map(transform)
    }
    
    func compactMap<T>(_ transform: ((Key, Value)) throws -> T?) rethrows -> [T] {
        return try self.buffer.compactMap(transform)
    }
    
    func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> [Key: T] {
        return try self.buffer.mapValues(transform)
    }
    
    func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> [(Key, T)] {
        return Array(try self.mapValues(transform))
    }
    
    func mapValues(_ transform: (Value) throws -> Value) rethrows -> KeyedStorage {
        return KeyedStorage(try self.mapValues(transform))
    }
}

extension KeyedStorage: Sequence {
    typealias Iterator = Buffer.Iterator
    
    func makeIterator() -> Iterator {
        return self.buffer.makeIterator()
    }
}

extension KeyedStorage: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(Dictionary(uniqueKeysWithValues: elements))
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
        self.attributes = [:]
        self.elements = [:]
    }
    
    init<E, A>(elements: E, attributes: A)
        where E: Sequence, E.Element == (Key, Element), A: Sequence, A.Element == (Key, Attribute)
    {
        self.elements = Elements(Dictionary(uniqueKeysWithValues: elements))
        self.attributes = Attributes(Dictionary(uniqueKeysWithValues: attributes))
    }
    
    init(elements: [Key: Element], attributes: [Key: Attribute]) {
        self.elements = Elements(elements)
        self.attributes = Attributes(attributes)
    }
    
    func unbox() -> (elements: Elements, attributes: Attributes) {
        return (
            elements: self.elements,
            attributes: self.attributes
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
