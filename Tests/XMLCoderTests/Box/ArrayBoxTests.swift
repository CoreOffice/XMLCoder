//
//  ArrayBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class ArrayBoxTests: XCTestCase {
    lazy var box = ArrayBox([Box("foo"), Box(42)])
    
    func testUnbox() {
        XCTAssertEqual(box.unbox(), [Box("foo"), Box(42)])
    }
    
    func testXMLString() {
        XCTAssertEqual(box.xmlString, "['foo', 42]")
    }
    
    func testDescription() {
        XCTAssertEqual(box.description, "[foo, 42]")
    }
}
