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
        
        let xmlString = "<container><value>42</value></container>"
        let xmlData = xmlString.data(using: .utf8)!
        
        let root: _XMLElement? = try parser.parse(with: xmlData)
        
        let expected = _XMLElement(
            key: "container",
            elements: [
                "value": [
                    _XMLElement(
                        key: "value",
                        value: "42"
                    )
                ]
            ]
        )
        XCTAssertEqual(root, expected)
    }
}
