//
//  BoxTreeTests.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 07/04/2019.
//

import XCTest
@testable import XMLCoder

class BoxTreeTests: XCTestCase {
    func testNestedValues() {
        let e1 = XMLCoderElement(
            key: "foo",
            value: "456",
            elements: [],
            attributes: [Attribute(key: "id", value: "123")]
        )
        let e2 = XMLCoderElement(
            key: "foo",
            value: "123",
            elements: [],
            attributes: [Attribute(key: "id", value: "789")]
        )
        let root = XMLCoderElement(
            key: "container",
            value: nil,
            elements: [e1, e2],
            attributes: []
        )

        let boxTree = root.transformToBoxTree()
        let foo = boxTree.elements["foo"]

        XCTAssertEqual(foo.count, 2)
    }
}
