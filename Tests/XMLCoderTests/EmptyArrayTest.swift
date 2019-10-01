//
//  EmptyArrayTest.swift
//  XMLCoderTests
//
//  Created by Benjamin Wetherfield on 10/1/19.
//

import Foundation
import XCTest
@testable import XMLCoder

struct Empty: Equatable, Codable { }

struct EmptyArray: Equatable, Codable {
    enum CodingKeys: String, CodingKey { case empties = "empty" }
    let empties: [Empty]
}

struct EmptyWrapper: Equatable, Codable {
    let empty: Empty
}

private let xml = """
<container>
    <empty/>
    <empty/>
    <empty/>
</container>
"""

private let xmlArray = """
<container>
    <empty/>
    <empty/>
    <empty/>
</container>
"""

private let xmlContainsEmpty = """
<container>
    <empty/>
</container>
"""

class EmptyArrayTest: XCTestCase {
    
    func testEmptyArrayDecode() throws {
        let decoded = try XMLDecoder().decode([Empty].self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(decoded, [Empty(), Empty(), Empty()])
    }
    
    func testWrappedEmptyArrayDecode() throws {
        let decoded = try XMLDecoder().decode(EmptyArray.self, from: xmlArray.data(using: .utf8)!)
        XCTAssertEqual(decoded, EmptyArray(empties: [Empty(), Empty(), Empty()]))
    }
    
    func testWrappedEmptyDecode() throws {
        let decoded = try XMLDecoder().decode(EmptyWrapper.self, from: xmlContainsEmpty.data(using: .utf8)!)
        XCTAssertEqual(decoded, EmptyWrapper(empty: Empty()))
    }
}
