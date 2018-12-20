//
//  DictionaryBox.swift
//  XMLCoderPackageDescription
//
//  Created by Vincent Esche on 11/19/18.
//

import Foundation

// Minimalist implementation of an order-preserving keyed box:
class DictionaryBox {
    typealias Key = String
    typealias Value = Box
    
    typealias Unboxed = [Key: Value]
    
    private(set) var unboxed: Unboxed
    
    var count: Int {
        return self.unboxed.count
    }
    
    var keys: Unboxed.Keys {
        return self.unboxed.keys
    }
    
    subscript(key: Key) -> Value? {
        get {
            return self.unboxed[key]
        }
        set {
            self.unboxed[key] = newValue
        }
    }
    
    init(_ unboxed: Unboxed = [:]) {
        self.unboxed = unboxed
    }
    
    convenience init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Element == (Key, Value) {
        let unboxed = try Dictionary(keysAndValues, uniquingKeysWith: combine)
        self.init(unboxed)
    }
    
    func unbox() -> Unboxed {
        return self.unboxed
    }
    
    func filter(_ isIncluded: (Key, Value) throws -> Bool) rethrows -> [(Key, Value)] {
        return try self.unboxed.filter(isIncluded)
    }
    
    func map<T>(_ transform: (Key, Value) throws -> T) rethrows -> [T] {
        return try self.unboxed.map(transform)
    }
    
    func compactMap<T>(_ transform: ((Key, Value)) throws -> T?) rethrows -> [T] {
        return try self.unboxed.compactMap(transform)
    }
    
    func mapValues(_ transform: (Value) throws -> Value) rethrows -> DictionaryBox {
        return DictionaryBox(try self.unboxed.mapValues(transform))
    }
}

extension DictionaryBox: Box {
    var isNull: Bool {
        return false
    }
    
    var isFragment: Bool {
        return false
    }
    
    func xmlString() -> String? {
        return nil
    }
}

extension DictionaryBox: Sequence {
    typealias Iterator = Unboxed.Iterator
    
    func makeIterator() -> Iterator {
        return self.unboxed.makeIterator()
    }
}

extension DictionaryBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
