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
    
    typealias FromXMLString = (String) -> Boxed?
    
    let secondsSince1970: FromXMLString = { xmlString in
        return Boxed(secondsSince1970: xmlString)
    }
    let millisecondsSince1970: FromXMLString = { xmlString in
        return Boxed(millisecondsSince1970: xmlString)
    }
    let iso8601: FromXMLString = { xmlString in
        return Boxed(iso8601: xmlString)
    }
    lazy var formatter: FromXMLString = { xmlString in
        return Boxed(xmlString: xmlString, formatter: self.customFormatter)
    }
    
    let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    func testUnbox() {
        let values: [Boxed.Unboxed] = [
            Date(timeIntervalSince1970: 0.0),
            Date(timeIntervalSinceReferenceDate: 0.0),
            Date(),
        ]
        
        for unboxed in values {
            let box = Boxed(unboxed, format: .iso8601)
            XCTAssertEqual(box.unbox(), unboxed)
        }
    }
    
    func testXMLString() {
        let values: [(String, FromXMLString)] = [
            ("-1000.0", secondsSince1970),
            ("0.0", secondsSince1970),
            ("1000.0", secondsSince1970),
            
            ("-1000.0", millisecondsSince1970),
            ("0.0", millisecondsSince1970),
            ("1000.0", millisecondsSince1970),
            
            ("1970-01-23T01:23:45Z", iso8601),
            
            ("1970-01-23 01:23:45", formatter),
        ]
        
        for (string, fromXMLString) in values {
            let box = fromXMLString(string)!
            XCTAssertEqual(box.xmlString(), string)
        }
    }
    
    func testValidValues() {
        typealias Constructor = (String) -> Boxed?
        
        let values: [(String, FromXMLString)] = [
            ("-1000.0", secondsSince1970),
            ("0", secondsSince1970),
            ("1000.0", secondsSince1970),
            
            ("-1000.0", millisecondsSince1970),
            ("0", millisecondsSince1970),
            ("1000.0", millisecondsSince1970),

            ("1970-01-23T01:23:45Z", iso8601),
            
            ("1970-01-23 01:23:45", formatter),
        ]
        
        for (string, fromXMLString) in values {
            let box = fromXMLString(string)
            XCTAssertNotNil(box)
        }
    }
    
    func testInvalidValues() {
        typealias Constructor = (String) -> Boxed?
        
        let values: [(String, Constructor)] = [
            ("foobar", secondsSince1970),
            ("", secondsSince1970),
            
            ("foobar", millisecondsSince1970),
            ("", millisecondsSince1970),
            
            ("foobar", iso8601),
            ("", iso8601),
            
            ("foobar", formatter),
            ("", formatter),
        ]
        
        for (string, fromXMLString) in values {
            let box = fromXMLString(string)
            XCTAssertNil(box)
        }
    }
}
