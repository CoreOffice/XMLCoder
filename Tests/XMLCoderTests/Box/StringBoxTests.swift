//
//  StringBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class StringBoxTests: XCTestCase {
    typealias Boxed = StringBox

    func testIsNull() {
        let box = Boxed("lorem ipsum")
        XCTAssertEqual(box.isNull, false)
    }

    func testUnbox() {
        let values: [Boxed.Unboxed] = [
            "",
            "false",
            "42",
            "12.34",
            "lorem ipsum",
        ]

        for unboxed in values {
            let box = Boxed(unboxed)
            XCTAssertEqual(box.unbox(), unboxed)
        }
    }

    func testXMLString() {
        let values: [(Boxed.Unboxed, String)] = [
            ("", ""),
            ("false", "false"),
            ("42", "42"),
            ("12.34", "12.34"),
            ("lorem ipsum", "lorem ipsum"),
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
            // none.
        ]

        for string in values {
            let box = Boxed(xmlString: string)
            XCTAssertNil(box)
        }
    }
}
