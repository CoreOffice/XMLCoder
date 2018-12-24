//
//  BoolBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class BoolBoxTests: XCTestCase {
    typealias Boxed = BoolBox

    func testIsNull() {
        let box = Boxed(false)
        XCTAssertEqual(box.isNull, false)
    }

    func testUnbox() {
        let values: [Boxed.Unboxed] = [
            false,
            true,
        ]

        for unboxed in values {
            let box = Boxed(unboxed)
            XCTAssertEqual(box.unbox(), unboxed)
        }
    }

    func testXMLString() {
        let values: [(Boxed.Unboxed, String)] = [
            (false, "false"),
            (true, "true"),
        ]

        for (unboxed, string) in values {
            let box = Boxed(unboxed)
            XCTAssertEqual(box.xmlString(), string)
        }
    }

    func testValidValues() {
        let values: [String] = [
            "0",
            "1",
            "false",
            "true",
        ]

        for string in values {
            let box = Boxed(xmlString: string)
            XCTAssertNotNil(box)
        }
    }

    func testInvalidValues() {
        let values: [String] = [
            "42",
            "foobar",
            "",
        ]

        for string in values {
            let box = Boxed(xmlString: string)
            XCTAssertNil(box)
        }
    }
}
