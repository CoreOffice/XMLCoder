// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Vincent Esche on 12/24/18.
//

import XCTest
@testable import XMLCoder

class XMLElementTests: XCTestCase {
    func testInitNull() {
        let null = XMLCoderElement(key: "foo")

        XCTAssertEqual(null.key, "foo")
        XCTAssertNil(null.stringValue)
        XCTAssertEqual(null.elements, [])
        XCTAssertEqual(null.attributes, [])
    }

    func testInitUnkeyed() {
        let keyed = XMLCoderElement(key: "foo", isStringBoxCDATA: false, box: UnkeyedBox())

        XCTAssertEqual(keyed.key, "foo")
        XCTAssertNil(keyed.stringValue)
        XCTAssertEqual(keyed.elements, [])
        XCTAssertEqual(keyed.attributes, [])
    }

    func testInitKeyed() {
        let keyed = XMLCoderElement(key: "foo", isStringBoxCDATA: false, box: KeyedBox(
            elements: [] as [(String, Box)],
            attributes: [("baz", NullBox()), ("blee", IntBox(42))] as [(String, SimpleBox)]
        ))

        XCTAssertEqual(keyed.key, "foo")
        XCTAssertNil(keyed.stringValue)
        XCTAssertEqual(keyed.elements, [])
        XCTAssertEqual(keyed.attributes, [Attribute(key: "blee", value: "42")])
    }

    func testInitSimple() {
        let keyed = XMLCoderElement(key: "foo", isStringBoxCDATA: false, box: StringBox("bar"))
        let element = XMLCoderElement(stringValue: "bar")

        XCTAssertEqual(keyed.key, "foo")
        XCTAssertNil(keyed.stringValue)
        XCTAssertEqual(keyed.elements, [element])
        XCTAssertEqual(keyed.attributes, [])
    }
}
