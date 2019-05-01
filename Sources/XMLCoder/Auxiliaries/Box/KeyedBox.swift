//
//  KeyedBox.swift
//  XMLCoder
//
//  Created by Vincent Esche on 11/19/18.
//

struct KeyedBox {
    typealias Key = String
    typealias Attribute = SimpleBox
    typealias Element = Box

    typealias Attributes = KeyedStorage<Key, Attribute>
    typealias Elements = KeyedStorage<Key, Element>

    var elements = Elements()
    var attributes = Attributes()

    var unboxed: (elements: Elements, attributes: Attributes) {
        return (
            elements: elements,
            attributes: attributes
        )
    }
}

extension KeyedBox {
    init<E, A>(elements: E, attributes: A)
        where E: Sequence, E.Element == (Key, Element),
        A: Sequence, A.Element == (Key, Attribute) {
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
