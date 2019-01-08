//
//  IntBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class IntBoxTests: XCTestCase {
    typealias Boxed = IntBox

    func testIsNull() {
        let box = Boxed(-42)
        XCTAssertEqual(box.isNull, false)
    }

    func testUnbox() {
        let values: [Boxed.Unboxed] = [
            -42,
            42,
            0,
        ]

        for unboxed in values {
            let box = Boxed(unboxed)
            XCTAssertEqual(box.unbox(), unboxed)
        }
    }

    func testXMLString() {
        let values: [(Boxed.Unboxed, String)] = [
            (-42, "-42"),
            (42, "42"),
            (0, "0"),
        ]

        for (unboxed, string) in values {
            let box = Boxed(unboxed)
            XCTAssertEqual(box.xmlString(), string)
        }
    }

    func testValidValues() {
        let values: [String] = [
            "-1",
            "0",
            "12678967543233",
            "+100000",
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
