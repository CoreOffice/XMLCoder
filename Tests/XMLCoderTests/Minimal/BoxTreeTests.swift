//
//  BoxTreeTests.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 07/04/2019.
//

import XCTest
@testable import XMLCoder

class BoxTreeTests: XCTestCase {
    func testNestedValues() throws {
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
        // FIXME: Use `XCTUnwrap` when commonly available
        guard let boxTree = root.transformToBoxTree() as? KeyedBox else {
            XCTFail("boxtTree is not a KeyedBox");
            return
        }
        let foo = boxTree.elements["foo"]
        XCTAssertEqual(foo.count, 2)
    }
}
