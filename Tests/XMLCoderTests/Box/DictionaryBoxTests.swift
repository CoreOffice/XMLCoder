//
//  ArrayBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class DictionaryBoxTests: XCTestCase {
    lazy var box = DictionaryBox(["foo": Box("bar"), "baz": Box(42)])
    
    func testUnbox() {
        XCTAssertEqual(box.unbox(), ["foo": Box("bar"), "baz": Box(42)])
    }
    
    func testXMLString() {
        XCTAssertEqual(box.xmlString, "['baz': 42, 'foo': 'bar']")
    }
    
    func testDescription() {
        // Element order is undefined, hence we just check for infixes:
        XCTAssertTrue(box.description.contains("\"baz\": 42"))
        XCTAssertTrue(box.description.contains("\"foo\": bar"))
        XCTAssertTrue(box.description.contains(", "))
        XCTAssertTrue(box.description.hasPrefix("["))
        XCTAssertTrue(box.description.hasSuffix("]"))
    }
}
