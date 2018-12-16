//
//  ArrayTest.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 19/11/2018.
//

import Foundation
import XCTest
@testable import XMLCoder

private struct Container: Codable, Equatable {
    let elements: [String]

    enum CodingKeys: String, CodingKey {
        case elements = "element"
    }
}

class ArrayTest: XCTestCase {
    func testEmpty() {
        let decoder = XMLDecoder()
        
        do {
            let xml = """
<?xml version="1.0" encoding="UTF-8"?>
<elements>
</elements>
""".data(using: .utf8)!
            
            let container = try decoder.decode(Container.self, from: xml)
            XCTAssertEqual(container.elements, [])
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
    <element>foo</element>
</elements>
""".data(using: .utf8)!
            
            let container = try decoder.decode(Container.self, from: xml)
            XCTAssertEqual(container.elements, ["foo"])
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
    <element>foo</element>
    <element>bar</element>
</elements>
""".data(using: .utf8)!
            
            let container = try decoder.decode(Container.self, from: xml)
            XCTAssertEqual(container.elements, ["foo", "bar"])
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
