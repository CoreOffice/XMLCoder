//
//  DataBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/19/18.
//

import XCTest
@testable import XMLCoder

class DataBoxTests: XCTestCase {
    typealias Boxed = DataBox
    
    typealias FromXMLString = (String) -> Boxed?
    
    let base64: FromXMLString = { xmlString in
        return Boxed(base64: xmlString)
    }
    
    func testUnbox() {
        let values: [Boxed.Unboxed] = [
            Data(base64Encoded: "bG9yZW0gaXBzdW0=")!,
            Data(),
        ]
        
        for unboxed in values {
            let box = Boxed(unboxed, format: .base64)
            XCTAssertEqual(box.unbox(), unboxed)
        }
    }
    
    func testXMLString() {
        let values: [(String, FromXMLString)] = [
            ("bG9yZW0gaXBzdW0=", base64),
            ("ZG9sb3Igc2l0IGFtZXQ=", base64),
            ("Y29uc2VjdGV0dXIgYWRpcGlzY2luZyBlbGl0", base64),
        ]
        
        for (string, fromXMLString) in values {
            let box = fromXMLString(string)!
            XCTAssertEqual(box.xmlString(), string)
        }
    }
    
    func testValidValues() {
        typealias Constructor = (String) -> Boxed?
        
        let values: [(String, FromXMLString)] = [
            ("bG9yZW0gaXBzdW0=", base64),
            ("ZG9sb3Igc2l0IGFtZXQ=", base64),
            ("Y29uc2VjdGV0dXIgYWRpcGlzY2luZyBlbGl0", base64),
        ]
        
        for (string, fromXMLString) in values {
            let box = fromXMLString(string)
            XCTAssertNotNil(box)
        }
    }
    
    func testInvalidValues() {
        typealias Constructor = (String) -> Boxed?
        
        let values: [(String, Constructor)] = [
            ("lorem ipsum", base64),
        ]
        
        for (string, fromXMLString) in values {
            let box = fromXMLString(string)
            XCTAssertNil(box)
        }
    }
}
