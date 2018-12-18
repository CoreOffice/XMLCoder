//
//  StringBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class StringBoxTests: XCTestCase {
    lazy var box = StringBox("lorem ipsum")
    
    func testUnbox() {
        XCTAssertEqual(box.unbox(), "lorem ipsum")
    }
    
    func testXMLString() {
        XCTAssertEqual(box.xmlString, "lorem ipsum")
    }
    
    func testDescription() {
        XCTAssertEqual(box.description, "lorem ipsum")
    }
}
