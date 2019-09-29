//
//  EmptyElementEmptyStringTests.swift
//  XMLCoderTests
//
//  Created by James Bean on 9/29/19.
//

import XCTest
import XMLCoder

class EmptyElementEmptyStringTests: XCTestCase {

    struct Container: Equatable, Codable {
        let attribute: String?
        let value: String
    }

    func testEmptyElementEmptyStringDecoding() throws {
        let xml = """
        <container></container>
        """
        let expected = Container(attribute: nil, value: "")
        let result = try XMLDecoder().decode(Container.self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }

    func testEmptyElementEmptyStringWithAttributeDecoding() throws {
        let xml = """
        <container attribute="x"></container>
        """
        let expected = Container(attribute: "x", value: "")
        let result = try XMLDecoder().decode(Container.self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }
}
