//
//  XMLStackParserTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/21/18.
//

import XCTest
@testable import XMLCoder

class XMLStackParserTests: XCTestCase {
    func testParseWith() throws {
        let parser = _XMLStackParser()

        let xmlString =
            """
            <container>
                <value>42</value>
                <data><![CDATA[lorem ipsum]]></data>
            </container>
            """
        let xmlData = xmlString.data(using: .utf8)!

        let root: _XMLElement? = try parser.parse(with: xmlData,
                                                  errorContextLength: 0)

        let expected = _XMLElement(
            key: "container",
            elements: [
                _XMLElement(
                    key: "value",
                    value: "42"
                ),
                _XMLElement(
                    key: "data",
                    value: "lorem ipsum"
                ),
            ]
        )
        XCTAssertEqual(root, expected)
    }

    func testParseWithThrow() throws {
        let parser = _XMLStackParser()

        let xmlString = "lorem ipsum"
        let xmlData = xmlString.data(using: .utf8)!

        XCTAssertThrowsError(try parser.parse(with: xmlData,
                                              errorContextLength: 0))
    }
}
