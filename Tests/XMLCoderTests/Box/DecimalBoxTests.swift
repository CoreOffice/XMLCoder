//
//  DecimalBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class DecimalBoxTests: XCTestCase {
    lazy var box = DecimalBox(Decimal(string: "12.34")!)
    
    func testUnbox() {
        XCTAssertEqual(box.unbox(), Decimal(string: "12.34")!)
    }
    
    func testXMLString() {
        XCTAssertEqual(box.xmlString, "12.34")
    }
    
    func testDescription() {
        XCTAssertEqual(box.description, "12.34")
    }
}
