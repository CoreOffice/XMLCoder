//
//  DecimalBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class DecimalBoxTests: XCTestCase {
    typealias Boxed = DecimalBox

    func testIsNull() {
        let box = Boxed(42.0)
        XCTAssertEqual(box.isNull, false)
    }

    func testUnbox() {
        let values: [Boxed.Unboxed] = [
            -1.23,
            12_678_967.543233,
            +100_000.00,
            210,
        ]

        for unboxed in values {
            let box = Boxed(unboxed)
            XCTAssertEqual(box.unbox(), unboxed)
        }
    }

    func testXMLString() {
        let values: [(Boxed.Unboxed, String)] = [
            (12.34, "12.34"),
            (0.0, "0"),
        ]

        for (bool, string) in values {
            let box = Boxed(bool)
            XCTAssertEqual(box.xmlString(), string)
        }
    }

    func testValidValues() {
        let values: [String] = [
            "-1.23",
            "12678967.543233",
            "+100000.00",
            "210",
        ]

        for string in values {
            let box = Boxed(xmlString: string)
            XCTAssertNotNil(box)
        }
    }

    func testInvalidValues() {
        let values: [String] = [
            "foobar",
            "",
        ]

        for string in values {
            let box = Boxed(xmlString: string)
            XCTAssertNil(box)
        }
    }
}
