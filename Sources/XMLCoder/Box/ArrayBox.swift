//
//  ArrayBox.swift
//  XMLCoderPackageDescription
//
//  Created by Vincent Esche on 11/20/18.
//

import Foundation

// Minimalist implementation of an order-preserving unkeyed box:
internal class ArrayBox {
    typealias Element = Box
    typealias Unboxed = [Element]
    
    fileprivate var unboxed: Unboxed
    
    var xmlString: String {
        return self.unboxed.description
    }
    
    var count: Int {
        return self.unboxed.count
    }
    
    internal subscript(index: Int) -> Element {
        get {
            return self.unboxed[index]
        }
        set {
            self.unboxed[index] = newValue
        }
    }
    
    init(_ unboxed: Unboxed = []) {
        self.unboxed = unboxed
    }
    
    func unbox() -> Unboxed {
        return self.unboxed
    }
    
    func append(_ newElement: Element) {
        self.unboxed.append(newElement)
    }
    
    func insert(_ newElement: Element, at index: Int) {
        self.unboxed.insert(newElement, at: index)
    }
    
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        return try self.unboxed.filter(isIncluded)
    }
    
    func map<T>(_ transform: (Any) throws -> T) rethrows -> [T] {
        return try self.unboxed.map(transform)
    }
    
    func compactMap<T>(_ transform: (Any) throws -> T?) rethrows -> [T] {
        return try self.unboxed.compactMap(transform)
    }
}

extension ArrayBox: CustomStringConvertible {
    var description: String {
        return self.unboxed.description
    }
}
