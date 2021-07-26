// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Max Desiatov on 07/04/2019.
//

struct KeyedStorage<Key: Hashable & Comparable, Value> {
    typealias Buffer = [(Key, Value)]
    typealias KeyMap = [Key: [Int]]

    fileprivate var keyMap = KeyMap()
    fileprivate var buffer = Buffer()

    var isEmpty: Bool {
        return buffer.isEmpty
    }

    var count: Int {
        return buffer.count
    }

    var keys: [Key] {
        return buffer.map { $0.0 }
    }

    var values: [Value] {
        return buffer.map { $0.1 }
    }

    init<S>(_ sequence: S) where S: Sequence, S.Element == (Key, Value) {
        buffer = Buffer()
        keyMap = KeyMap()
        sequence.forEach { key, value in append(value, at: key) }
    }

    subscript(key: Key) -> [Value] {
        return keyMap[key]?.map { buffer[$0].1 } ?? []
    }

    mutating func append(_ value: Value, at key: Key) {
        let i = buffer.count
        buffer.append((key, value))
        if keyMap[key] != nil {
            keyMap[key]?.append(i)
        } else {
            keyMap[key] = [i]
        }
    }

    func map<T>(_ transform: (Key, Value) throws -> T) rethrows -> [T] {
        return try buffer.map(transform)
    }

    func compactMap<T>(
        _ transform: ((Key, Value)) throws -> T?
    ) rethrows -> [T] {
        return try buffer.compactMap(transform)
    }

    init() {}
}

extension KeyedStorage: Sequence {
    func makeIterator() -> Buffer.Iterator {
        return buffer.makeIterator()
    }
}

extension KeyedStorage: CustomStringConvertible {
    var description: String {
        let result = buffer.map { "\"\($0)\": \($1)" }.joined(separator: ", ")

        return "[\(result)]"
    }
}

extension KeyedStorage where Key == String, Value == Box {
    func merge(element: XMLCoderElement) -> KeyedStorage<String, Box> {
        var result = self

        let hasElements = !element.elements.isEmpty
        let hasAttributes = !element.attributes.isEmpty
        let hasText = element.stringValue != nil

        var numEmptyKey = 0
        var numNonEmptyKey = 0
        var filteredElements: [XMLCoderElement] = []
        for ele in element.elements {
            if ele.isWhitespaceWithNoElements() {
                numEmptyKey += 1
            } else {
                numNonEmptyKey += 1
                filteredElements.append(ele)
            }
        }
        let updatedElement: XMLCoderElement
        if numEmptyKey != 0 && numNonEmptyKey != 0 {
            updatedElement = XMLCoderElement(key: element.key, elements: filteredElements, attributes: element.attributes)
        } else {
            updatedElement = element
        }
        
        if hasElements || hasAttributes {
            let value = updatedElement.transformToBoxTree()
            result.append(value, at: updatedElement.key)
        } else if hasText {
            let value = updatedElement.transformToBoxTree()
            result.append(value, at: updatedElement.key)
        } else {
            result.append(SingleKeyedBox(key: updatedElement.key, element: NullBox()), at: updatedElement.key)
        }

        return result
    }
}
