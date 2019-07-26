//
//  SingleElementBox.swift
//  XMLCoder
//
//  Created by James Bean on 7/15/19.
//

/// A `Box` which contains a single `key` and `element` pair. This is useful for disambiguating elements which could either represent
/// an element nested in a keyed or unkeyed container, or an choice between multiple known-typed values (implemented in Swift using
/// enums with associated values).
struct SingleElementBox: SimpleBox {
    typealias Key = String
    typealias Attribute = SimpleBox
    typealias Attributes = KeyedStorage<Key, Attribute>

    var attributes = Attributes()
    var key: String = ""
    var element: Box = NullBox()
}

extension SingleElementBox: Box {
    var isNull: Bool {
        return false
    }

    func xmlString() -> String? {
        return nil
    }
}
