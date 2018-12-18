//
//  UIntBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class UIntBoxTests: XCTestCase {
    lazy var box = UIntBox(UInt(42))
    
    func testUnbox() {
        XCTAssertEqual(box.unbox(), 42)
    }
    
    func testXMLString() {
        XCTAssertEqual(box.xmlString, "42")
    }
    
    func testDescription() {
        XCTAssertEqual(box.description, "42")
    }
}
