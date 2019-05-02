//
//  KeyedStorage.swift
//  XMLCoder
//
//  Created by Max Desiatov on 07/04/2019.
//

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

    var keys: [Key] {
        return order
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

    func compactMap<T>(
        _ transform: ((Key, Value)) throws -> T?
    ) rethrows -> [T] {
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

private extension KeyedStorage where Key == String, Value == Box {
    mutating func merge(value: String, at key: String) {
        switch self[key] {
        case var unkeyedBox as UnkeyedBox:
            unkeyedBox.append(StringBox(value))
            self[key] = unkeyedBox
        case let stringBox as StringBox:
            self[key] = UnkeyedBox([stringBox, StringBox(value)])
        default:
            self[key] = StringBox(value)
        }
    }

    mutating func mergeElementsAttributes(from element: XMLCoderElement) {
        let hasValue = element.value != nil

        let key = element.key
        let content = element.transformToBoxTree()
        switch self[key] {
        case var unkeyedBox as UnkeyedBox:
            unkeyedBox.append(content)
            self[key] = unkeyedBox
        case let keyedBox as KeyedBox:
            self[key] = UnkeyedBox([keyedBox, content])
        case let box? where !hasValue:
            self[key] = UnkeyedBox([box, content])
        default:
            self[key] = content
        }
    }

    mutating func mergeNull(at key: String) {
        switch self[key] {
        case var unkeyedBox as UnkeyedBox:
            unkeyedBox.append(NullBox())
            self[key] = unkeyedBox
        case let box?:
            self[key] = UnkeyedBox([box, NullBox()])
        default:
            self[key] = NullBox()
        }
    }
}

extension KeyedStorage where Key == String, Value == Box {
    func merge(element: XMLCoderElement) -> KeyedStorage<String, Box> {
        var result = self

        let hasElements = !element.elements.isEmpty
        let hasAttributes = !element.attributes.isEmpty

        if hasElements || hasAttributes {
            result.mergeElementsAttributes(from: element)
        } else if let value = element.value {
            result.merge(value: value, at: element.key)
        } else {
            result.mergeNull(at: element.key)
        }

        return result
    }
}
