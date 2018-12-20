//
//  UnkeyedBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class DictionaryBoxTests: XCTestCase {
    lazy var box = DictionaryBox(["foo": StringBox("bar"), "baz": IntBox(42)])
    
    func testUnbox() {
        let unboxed = box.unbox()
        XCTAssertEqual(unboxed.count, 2)
        XCTAssertEqual(unboxed["foo"] as? StringBox, StringBox("bar"))
        XCTAssertEqual(unboxed["baz"] as? IntBox, IntBox(42))
    }
    
    func testXMLString() {
        XCTAssertEqual(box.xmlString(), nil)
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
