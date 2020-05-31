// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Vincent Esche on 12/21/18.
//

import XCTest
@testable import XMLCoder

class XMLStackParserTests: XCTestCase {
    func testParseWith() throws {
        let parser = XMLStackParser()

        let xmlString =
            """
            <container>
                <value>42</value>
                <data><![CDATA[lorem ipsum]]></data>
            </container>
            """
        let xmlData = xmlString.data(using: .utf8)!

        let root: XMLCoderElement? = try parser.parse(
            with: xmlData,
            errorContextLength: 0,
            shouldProcessNamespaces: false
        )

        let expected = XMLCoderElement(
            key: "container",
            elements: [
                XMLCoderElement(
                    key: "value",
                    stringValue: "42"
                ),
                XMLCoderElement(
                    key: "data",
                    cdataValue: "lorem ipsum"
                ),
            ]
        )
        XCTAssertEqual(root, expected)
    }

    func testParseWithThrow() throws {
        let parser = XMLStackParser()

        let xmlString = "lorem ipsum"
        let xmlData = xmlString.data(using: .utf8)!

        XCTAssertThrowsError(try parser.parse(
            with: xmlData,
            errorContextLength: 0,
            shouldProcessNamespaces: false
        ))
    }
}
