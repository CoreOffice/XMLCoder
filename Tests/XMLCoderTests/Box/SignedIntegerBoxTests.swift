//
//  SignedIntegerBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class SignedIntegerBoxTests: XCTestCase {
    lazy var negativeBox = SignedIntegerBox(-42)
    lazy var positiveBox = SignedIntegerBox(42)
    
    func testUnbox() {
        XCTAssertEqual(negativeBox.unbox(), -42)
        XCTAssertEqual(positiveBox.unbox(), 42)
    }
    
    func testXMLString() {
        XCTAssertEqual(negativeBox.xmlString, "-42")
        XCTAssertEqual(positiveBox.xmlString, "42")
    }
    
    func testDescription() {
        XCTAssertEqual(negativeBox.description, "-42")
        XCTAssertEqual(positiveBox.description, "42")
    }
}
