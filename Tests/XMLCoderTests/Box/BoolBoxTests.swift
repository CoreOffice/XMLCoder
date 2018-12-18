//
//  BoolBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class BoolBoxTests: XCTestCase {
    let falseBox = BoolBox(false)
    let trueBox = BoolBox(true)
    
    func testUnbox() {
        XCTAssertEqual(falseBox.unbox(), false)
        XCTAssertEqual(trueBox.unbox(), true)
    }
    
    func testXMLString() {
        XCTAssertEqual(falseBox.xmlString, "false")
        XCTAssertEqual(trueBox.xmlString, "true")
    }
    
    func testDescription() {
        XCTAssertEqual(falseBox.description, "false")
        XCTAssertEqual(trueBox.description, "true")
    }
}
