//
//  UnkeyedBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class KeyedBoxTests: XCTestCase {
    lazy var box = KeyedBox(
        elements: ["foo": StringBox("bar"), "baz": IntBox(42)],
        attributes: ["baz": StringBox("blee")]
    )

    func testUnbox() {
        let (elements, attributes) = box.unbox()

        XCTAssertEqual(elements.count, 2)
        XCTAssertEqual(elements["foo"] as? StringBox, StringBox("bar"))
        XCTAssertEqual(elements["baz"] as? IntBox, IntBox(42))

        XCTAssertEqual(attributes.count, 1)
        XCTAssertEqual(attributes["baz"] as? StringBox, StringBox("blee"))
    }

    func testXMLString() {
        XCTAssertEqual(box.xmlString(), nil)
    }
}
