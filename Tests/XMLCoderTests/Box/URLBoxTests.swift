//
//  URLBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/21/18.
//

import XCTest
@testable import XMLCoder

class URLBoxTests: XCTestCase {
    typealias Boxed = URLBox

    func testIsNull() {
        let box = Boxed(URL(string: "http://example.com")!)
        XCTAssertEqual(box.isNull, false)
    }

    func testUnbox() {
        let values: [Boxed.Unboxed] = [
            URL(string: "file:///")!,
            URL(string: "http://example.com")!,
        ]

        for unboxed in values {
            let box = Boxed(unboxed)
            XCTAssertEqual(box.unbox(), unboxed)
        }
    }

    func testXMLString() {
        let values: [(Boxed.Unboxed, String)] = [
            (URL(string: "file:///")!, "file:///"),
            (URL(string: "http://example.com")!, "http://example.com"),
        ]

        for (bool, string) in values {
            let box = Boxed(bool)
            XCTAssertEqual(box.xmlString(), string)
        }
    }

    func testValidValues() {
        let values: [String] = [
            "file:///",
            "http://example.com",
        ]

        for string in values {
            let box = Boxed(xmlString: string)
            XCTAssertNotNil(box)
        }
    }

    func testInvalidValues() {
        let values: [String] = [
            "foo\nbar",
            "",
        ]

        for string in values {
            let box = Boxed(xmlString: string)
            XCTAssertNil(box)
        }
    }
}
