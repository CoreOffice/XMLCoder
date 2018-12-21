//
//  KeyedTests.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 19/11/2018.
//

import XCTest
@testable import XMLCoder

class KeyedTests: XCTestCase {
    struct Container: Codable, Equatable {
        let value: [String: Int]
    }

    func testEmpty() {
        let decoder = XMLDecoder()
        
        do {
            let xmlString =
"""
<?xml version="1.0" encoding="UTF-8"?>
<container>
</container>
"""
                let xmlData = xmlString.data(using: .utf8)!
            
            let decoded = try decoder.decode(Container.self, from: xmlData)
            XCTAssertEqual(decoded.value, [:])
        } catch {
            XCTAssert(false, "failed to decode test xml: \(error)")
        }
    }
    
    func testSingleElement() {
        let decoder = XMLDecoder()
        
        do {
            let xmlString =
"""
<?xml version="1.0" encoding="UTF-8"?>
<container>
    <value>
        <foo>12</foo>
    </value>
</container>
"""
                let xmlData = xmlString.data(using: .utf8)!
            
            let decoded = try decoder.decode(Container.self, from: xmlData)
            XCTAssertEqual(decoded.value, ["foo": 12])
        } catch {
            XCTAssert(false, "failed to decode test xml: \(error)")
        }
    }
    
    func testMultiElement() {
        let decoder = XMLDecoder()
        
        do {
            let xmlString =
"""
<?xml version="1.0" encoding="UTF-8"?>
<container>
    <value>
        <foo>12</foo>
        <bar>34</bar>
    </value>
</container>
"""
                let xmlData = xmlString.data(using: .utf8)!
            
            let decoded = try decoder.decode(Container.self, from: xmlData)
            XCTAssertEqual(decoded.value, ["foo": 12, "bar": 34])
        } catch {
            XCTAssert(false, "failed to decode test xml: \(error)")
        }
    }
    
    func testAttribute() {
        let encoder = XMLEncoder()
        
        encoder.nodeEncodingStrategy = .custom { codableType, _ in
            return { _ in .attribute }
        }
        
        let container = Container(value: ["foo": 12, "bar": 34])
        
        XCTAssertThrowsError(
            try encoder.encode(container, withRootKey: "container")
        )
    }
    
    static var allTests = [
        ("testEmpty", testEmpty),
        ("testSingleElement", testSingleElement),
        ("testMultiElement", testMultiElement),
        ("testAttribute", testAttribute),
    ]
}
