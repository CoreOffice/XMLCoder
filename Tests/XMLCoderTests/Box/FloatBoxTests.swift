//
//  FloatBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class FloatBoxTests: XCTestCase {
    typealias Boxed = FloatBox

    func testIsNull() {
        let box = Boxed(42.0)
        XCTAssertEqual(box.isNull, false)
    }

    func testUnbox() {
        let values: [Boxed.Unboxed] = [
            -3e2,
            4268.22752e11,
            +24.3e-3,
            12,
            +3.5,
            -.infinity,
            -0,
        ]

        for unboxed in values {
            let box = Boxed(unboxed)
            XCTAssertEqual(box.unbox(), unboxed)
        }
    }

    func testXMLString() {
        let values: [(Boxed.Unboxed, String)] = [
            (42.0, "42.0"),
            (.infinity, "INF"),
            (-.infinity, "-INF"),
            (.nan, "NaN"),
        ]

        for (double, string) in values {
            let box = FloatBox(double)
            XCTAssertEqual(box.xmlString(), string)
        }
    }

    func testValidValues() {
        let values: [String] = [
            "-3E2",
            "4268.22752E11",
            "+24.3e-3",
            "12",
            "+3.5",
            "-INF",
            "-0",
            "NaN",
        ]

        for string in values {
            let box = FloatBox(xmlString: string)
            XCTAssertNotNil(box)
        }
    }

    func testInvalidValues() {
        let values: [String] = [
            "-3E2.4",
            "12E",
            "foobar",
            "",
        ]

        for string in values {
            let box = FloatBox(xmlString: string)
            XCTAssertNil(box)
        }
    }
}
