//
//  FloatBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class FloatBoxTests: XCTestCase {
    lazy var box = FloatBox(4.2)
    
    func testUnbox() {
        XCTAssertEqual(box.unbox(), 4.2)
    }
    
    func testXMLString() {
        XCTAssertEqual(box.xmlString, "4.2")
    }
    
    func testDescription() {
        XCTAssertEqual(box.description, "4.2")
    }
}
