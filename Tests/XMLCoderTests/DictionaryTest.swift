//
//  DictionaryTest.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 19/11/2018.
//

import Foundation
import XCTest
@testable import XMLCoder

class DictionaryTest: XCTestCase {
    struct Container: Codable, Equatable {
        let elements: [String: Int]
        
        enum CodingKeys: String, CodingKey {
            case elements = "element"
        }
    }
    
    func testEmpty() {
        let decoder = XMLDecoder()
        
        do {
            let xml = """
<?xml version="1.0" encoding="UTF-8"?>
<elements>
</elements>
""".data(using: .utf8)!
            
            let container = try decoder.decode(Container.self, from: xml)
            XCTAssertEqual(container.elements, [:])
        } catch {
            XCTAssert(false, "failed to decode test xml: \(error)")
        }
    }
    
    func testSingleElement() {
        let decoder = XMLDecoder()
        
        do {
            let xml = """
<?xml version="1.0" encoding="UTF-8"?>
<elements>
    <element>
        <foo>12</foo>
    </element>
</elements>
""".data(using: .utf8)!
            
            let container = try decoder.decode(Container.self, from: xml)
            XCTAssertEqual(container.elements, ["foo": 12])
        } catch {
            XCTAssert(false, "failed to decode test xml: \(error)")
        }
    }
    
    func testMultiElement() {
        let decoder = XMLDecoder()
        
        do {
            let xml = """
<?xml version="1.0" encoding="UTF-8"?>
<elements>
    <element>
        <foo>12</foo>
        <bar>34</bar>
    </element>
</elements>
""".data(using: .utf8)!
            
            let container = try decoder.decode(Container.self, from: xml)
            XCTAssertEqual(container.elements, ["foo": 12, "bar": 34])
        } catch {
            XCTAssert(false, "failed to decode test xml: \(error)")
        }
    }
    
    static var allTests = [
        ("testEmpty", testEmpty),
        ("testSingleElement", testSingleElement),
        ("testMultiElement", testMultiElement),
    ]
}
