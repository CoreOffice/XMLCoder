//
//  FlattenTests.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 07/04/2019.
//

import XCTest
@testable import XMLCoder

class FlattenTests: XCTestCase {
    func testNestedValues() {
        let e1 = XMLCoderElement(
            key: "foo",
            value: "456",
            elements: [],
            attributes: ["id": "123"]
        )
        let e2 = XMLCoderElement(
            key: "foo",
            value: "123",
            elements: [],
            attributes: ["id": "789"]
        )
        let root = XMLCoderElement(
            key: "container",
            value: nil,
            elements: [e1, e2],
            attributes: [:]
        )

        let flattened = root.flatten()

        guard let foo = flattened.elements["foo"] as? UnkeyedBox else { return }

        XCTAssertEqual(foo.count, 2)
    }
}
