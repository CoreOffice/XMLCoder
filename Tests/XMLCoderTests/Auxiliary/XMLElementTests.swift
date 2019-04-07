//
//  XMLElementTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/24/18.
//

import XCTest
@testable import XMLCoder

class XMLElementTests: XCTestCase {
    func testInitNull() {
        let null = XMLCoderElement(key: "foo")

        XCTAssertEqual(null.key, "foo")
        XCTAssertNil(null.value)
        XCTAssertEqual(null.elements, [])
        XCTAssertEqual(null.attributes, [:])
    }

    func testInitUnkeyed() {
        let keyed = XMLCoderElement(key: "foo", box: UnkeyedBox())

        XCTAssertEqual(keyed.key, "foo")
        XCTAssertNil(keyed.value)
        XCTAssertEqual(keyed.elements, [])
        XCTAssertEqual(keyed.attributes, [:])
    }

    func testInitKeyed() {
        let keyed = XMLCoderElement(key: "foo", box: KeyedBox(
            elements: [] as [(String, Box)],
            attributes: [("baz", NullBox()), ("blee", IntBox(42))] as [(String, SimpleBox)]
        ))

        XCTAssertEqual(keyed.key, "foo")
        XCTAssertNil(keyed.value)
        XCTAssertEqual(keyed.elements, [])
        XCTAssertEqual(keyed.attributes, ["blee": "42"])
    }

    func testInitSimple() {
        let keyed = XMLCoderElement(key: "foo", box: StringBox("bar"))

        XCTAssertEqual(keyed.key, "foo")
        XCTAssertEqual(keyed.value, "bar")
        XCTAssertEqual(keyed.elements, [])
        XCTAssertEqual(keyed.attributes, [:])
    }
}
