//
//  DateBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/19/18.
//

import XCTest
@testable import XMLCoder

class DateBoxTests: XCTestCase {
    typealias Boxed = DateBox
    
    func testUnbox() {
        let values: [Boxed.Unboxed] = [
            Date(timeIntervalSince1970: 0.0),
            Date(timeIntervalSinceReferenceDate: 0.0),
            Date(),
        ]
        
        for unboxed in values {
            let box = Boxed(unboxed)
            XCTAssertEqual(box.unbox(), unboxed)
        }
    }
    
    func testXMLString() {
        typealias Constructor = (String) -> Boxed?
        
        let secondsSince1970: Constructor = { Boxed(secondsSince1970: $0) }
        let millisecondsSince1970: Constructor = { Boxed(millisecondsSince1970: $0) }
        let iso8601: Constructor = { Boxed(iso8601: $0) }
        
        let values: [(String, Constructor)] = [
            ("-1000.0", secondsSince1970),
            ("0", secondsSince1970),
            ("1000.0", secondsSince1970),
            
            ("-1000.0", millisecondsSince1970),
            ("0", millisecondsSince1970),
            ("1000.0", millisecondsSince1970),
            
            ("1970-01-23T01:23:45Z", iso8601),
        ]
        
        for (string, constructor) in values {
            let box = constructor(string)
            
            XCTAssertEqual(box?.xmlString, string)
        }
    }
    
    func testValidValues() {
        typealias Constructor = (String) -> Boxed?
        
        let secondsSince1970: Constructor = { Boxed(secondsSince1970: $0) }
        let millisecondsSince1970: Constructor = { Boxed(millisecondsSince1970: $0) }
        let iso8601: Constructor = { Boxed(iso8601: $0) }
        
        let values: [(String, Constructor)] = [
            ("-1000.0", secondsSince1970),
            ("0", secondsSince1970),
            ("1000.0", secondsSince1970),
            
            ("-1000.0", millisecondsSince1970),
            ("0", millisecondsSince1970),
            ("1000.0", millisecondsSince1970),

            ("1970-01-23T01:23:45Z", iso8601),
        ]
        
        for (string, constructor) in values {
            let box = constructor(string)
            XCTAssertNotNil(box)
        }
    }
    
    func testInvalidValues() {
        typealias Constructor = (String) -> Boxed?
        
        let secondsSince1970: Constructor = { Boxed(secondsSince1970: $0) }
        let millisecondsSince1970: Constructor = { Boxed(millisecondsSince1970: $0) }
        let iso8601: Constructor = { Boxed(iso8601: $0) }
        
        let values: [(String, Constructor)] = [
            ("foobar", secondsSince1970),
            ("", secondsSince1970),
            
            ("foobar", millisecondsSince1970),
            ("", millisecondsSince1970),
            
            ("foobar", iso8601),
            ("", iso8601),
        ]
        
        for (string, constructor) in values {
            let box = constructor(string)
            XCTAssertNil(box)
        }
    }
}
