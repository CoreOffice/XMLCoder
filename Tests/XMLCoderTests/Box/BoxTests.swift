//
//  BoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class BoxTests: XCTestCase {
    let nullBox = Box()
    let boolBox = Box(true)
    let decimalBox = Box(Decimal(string: "4.2")!)
    let signedIntegerBox = Box(Int(-42))
    let unsignedIntegerBox = Box(UInt(42))
    let floatingPointBox = Box(4.2)
    let stringBox = Box("foo")
    let arrayBox = Box([])
    let dictionaryBox = Box([:])
    
    func testIsNull() {
        XCTAssertTrue(nullBox.isNull)
        
        XCTAssertFalse(boolBox.isNull)
        XCTAssertFalse(decimalBox.isNull)
        XCTAssertFalse(signedIntegerBox.isNull)
        XCTAssertFalse(unsignedIntegerBox.isNull)
        XCTAssertFalse(floatingPointBox.isNull)
        XCTAssertFalse(stringBox.isNull)
        XCTAssertFalse(arrayBox.isNull)
        XCTAssertFalse(dictionaryBox.isNull)
    }
    
    func testIsFragment() {
        XCTAssertTrue(nullBox.isFragment)
        XCTAssertTrue(boolBox.isFragment)
        XCTAssertTrue(decimalBox.isFragment)
        XCTAssertTrue(signedIntegerBox.isFragment)
        XCTAssertTrue(unsignedIntegerBox.isFragment)
        XCTAssertTrue(floatingPointBox.isFragment)
        XCTAssertTrue(stringBox.isFragment)

        XCTAssertFalse(arrayBox.isFragment)
        XCTAssertFalse(dictionaryBox.isFragment)
    }
    
    func testBool() {
        XCTAssertNil(nullBox.bool)
        
        XCTAssertNotNil(boolBox.bool)
        
        XCTAssertNil(decimalBox.bool)
        XCTAssertNil(signedIntegerBox.bool)
        XCTAssertNil(unsignedIntegerBox.bool)
        XCTAssertNil(floatingPointBox.bool)
        XCTAssertNil(stringBox.bool)
        XCTAssertNil(arrayBox.bool)
        XCTAssertNil(dictionaryBox.bool)
    }
    
    func testDecimal() {
        XCTAssertNil(nullBox.decimal)
        XCTAssertNil(boolBox.decimal)
        
        XCTAssertNotNil(decimalBox.decimal)
        
        XCTAssertNil(signedIntegerBox.decimal)
        XCTAssertNil(unsignedIntegerBox.decimal)
        XCTAssertNil(floatingPointBox.decimal)
        XCTAssertNil(stringBox.decimal)
        XCTAssertNil(arrayBox.decimal)
        XCTAssertNil(dictionaryBox.decimal)
    }
    
    func testSignedInteger() {
        XCTAssertNil(nullBox.signedInteger)
        XCTAssertNil(boolBox.signedInteger)
        XCTAssertNil(decimalBox.signedInteger)
        
        XCTAssertNotNil(signedIntegerBox.signedInteger)
        
        XCTAssertNil(unsignedIntegerBox.signedInteger)
        XCTAssertNil(floatingPointBox.signedInteger)
        XCTAssertNil(stringBox.signedInteger)
        XCTAssertNil(arrayBox.signedInteger)
        XCTAssertNil(dictionaryBox.signedInteger)
    }
    
    func testUnsignedInteger() {
        XCTAssertNil(nullBox.unsignedInteger)
        XCTAssertNil(boolBox.unsignedInteger)
        XCTAssertNil(decimalBox.unsignedInteger)
        XCTAssertNil(signedIntegerBox.unsignedInteger)
        
        XCTAssertNotNil(unsignedIntegerBox.unsignedInteger)
        
        XCTAssertNil(floatingPointBox.unsignedInteger)
        XCTAssertNil(stringBox.unsignedInteger)
        XCTAssertNil(arrayBox.unsignedInteger)
        XCTAssertNil(dictionaryBox.unsignedInteger)
    }
    
    func testFloatingPoint() {
        XCTAssertNil(nullBox.floatingPoint)
        XCTAssertNil(boolBox.floatingPoint)
        XCTAssertNil(decimalBox.floatingPoint)
        XCTAssertNil(signedIntegerBox.floatingPoint)
        XCTAssertNil(unsignedIntegerBox.floatingPoint)
        
        XCTAssertNotNil(floatingPointBox.floatingPoint)
        
        XCTAssertNil(stringBox.floatingPoint)
        XCTAssertNil(arrayBox.floatingPoint)
        XCTAssertNil(dictionaryBox.floatingPoint)
    }
    
    func testString() {
        XCTAssertNil(nullBox.string)
        XCTAssertNil(boolBox.string)
        XCTAssertNil(decimalBox.string)
        XCTAssertNil(signedIntegerBox.string)
        XCTAssertNil(unsignedIntegerBox.string)
        XCTAssertNil(floatingPointBox.string)
        
        XCTAssertNotNil(stringBox.string)
        
        XCTAssertNil(arrayBox.string)
        XCTAssertNil(dictionaryBox.string)
    }
    
    func testArray() {
        XCTAssertNil(nullBox.array)
        XCTAssertNil(boolBox.array)
        XCTAssertNil(decimalBox.array)
        XCTAssertNil(signedIntegerBox.array)
        XCTAssertNil(unsignedIntegerBox.array)
        XCTAssertNil(floatingPointBox.array)
        XCTAssertNil(stringBox.array)
        
        XCTAssertNotNil(arrayBox.array)
        
        XCTAssertNil(dictionaryBox.array)
    }
    
    func testDictionary() {
        XCTAssertNil(nullBox.dictionary)
        XCTAssertNil(boolBox.dictionary)
        XCTAssertNil(decimalBox.dictionary)
        XCTAssertNil(signedIntegerBox.dictionary)
        XCTAssertNil(unsignedIntegerBox.dictionary)
        XCTAssertNil(floatingPointBox.dictionary)
        XCTAssertNil(stringBox.dictionary)
        XCTAssertNil(arrayBox.dictionary)
        
        XCTAssertNotNil(dictionaryBox.dictionary)
    }
    
    func testXMLString() {
        XCTAssertEqual(nullBox.xmlString, "")
        XCTAssertEqual(boolBox.xmlString, "true")
        XCTAssertEqual(decimalBox.xmlString, "4.2")
        XCTAssertEqual(signedIntegerBox.xmlString, "-42")
        XCTAssertEqual(unsignedIntegerBox.xmlString, "42")
        XCTAssertEqual(floatingPointBox.xmlString, "4.2")
        XCTAssertEqual(stringBox.xmlString, "foo")
        XCTAssertEqual(arrayBox.xmlString, "[]")
        XCTAssertEqual(dictionaryBox.xmlString, "[]")
    }
    
    func testUnbox() throws {
        XCTAssertEqual(try boolBox.unbox(), true)
        XCTAssertEqual(try decimalBox.unbox(), Decimal(string: "4.2")!)
        XCTAssertEqual(try signedIntegerBox.unbox(), Int(-42))
        XCTAssertEqual(try unsignedIntegerBox.unbox(), UInt(42))
        XCTAssertEqual(try floatingPointBox.unbox(), 4.2)
        XCTAssertEqual(try stringBox.unbox(), "foo")
        XCTAssertEqual(try arrayBox.unbox(), [])
        XCTAssertEqual(try dictionaryBox.unbox(), [:])
    }
}
