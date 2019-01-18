//
//  UnkeyedBox.swift
//  XMLCoderPackageDescription
//
//  Created by Vincent Esche on 11/20/18.
//

import Foundation

// Minimalist implementation of an order-preserving unkeyed box:
struct UnkeyedBox {
    typealias Element = Box
    typealias Unboxed = [Element]

    private(set) var unboxed: Unboxed

    var count: Int {
        return unboxed.count
    }

    subscript(index: Int) -> Element {
        get {
            return unboxed[index]
        }
        set {
            unboxed[index] = newValue
        }
    }

    init(_ unboxed: Unboxed = []) {
        self.unboxed = unboxed
    }

    func unbox() -> Unboxed {
        return unboxed
    }

    mutating func append(_ newElement: Element) {
        unboxed.append(newElement)
    }

    mutating func insert(_ newElement: Element, at index: Int) {
        unboxed.insert(newElement, at: index)
    }
}

extension UnkeyedBox: Box {
    var isNull: Bool {
        return false
    }

    func xmlString() -> String? {
        return nil
    }
}

extension UnkeyedBox: Sequence {
    typealias Iterator = Unboxed.Iterator

    func makeIterator() -> Iterator {
        return unboxed.makeIterator()
    }
}

extension UnkeyedBox: CustomStringConvertible {
    var description: String {
        return "\(unboxed)"
    }
}
