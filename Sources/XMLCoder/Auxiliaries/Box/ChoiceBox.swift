//
//  ChoiceBox.swift
//  XMLCoder
//
//  Created by James Bean on 7/18/19.
//

/// A `Box` which represents an element which is known to contain an XML choice element.
struct ChoiceBox {
    var key: String = ""
    var element: Box = NullBox()
}

extension ChoiceBox: Box {
    var isNull: Bool {
        return false
    }

    func xmlString() -> String? {
        return nil
    }
}

extension ChoiceBox: SimpleBox {}

extension ChoiceBox {
    init?(_ keyedBox: KeyedBox) {
        guard let firstKey = keyedBox.elements.keys.first else { return nil }
        let firstElement = keyedBox.elements[firstKey]
        self.init(key: firstKey, element: firstElement)
    }
}
