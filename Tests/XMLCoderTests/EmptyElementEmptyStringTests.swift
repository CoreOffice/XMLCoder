//
//  EmptyElementEmptyStringTests.swift
//  XMLCoderTests
//
//  Created by James Bean on 9/29/19.
//

import XCTest
import XMLCoder

class EmptyElementEmptyStringTests: XCTestCase {
    struct Parent: Equatable, Codable {
        let thing: Thing
    }

    struct Thing: Equatable, Codable {
        let attribute: String?
        let value: String
    }

    func testEmptyElementEmptyStringDecoding() throws {
        let xml = """
        <thing></thing>
        """
        let expected = Thing(attribute: nil, value: "")
        let result = try XMLDecoder().decode(Thing.self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }

    func testEmptyElementEmptyStringWithAttributeDecoding() throws {
        let xml = """
        <thing attribute="x"></thing>
        """
        let expected = Thing(attribute: "x", value: "")
        let result = try XMLDecoder().decode(Thing.self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }

    func testArrayOfEmptyElementStringDecoding() throws {
        let xml = """
        <container>
            <thing></thing>
            <thing attribute="x"></thing>
            <thing></thing>
        </container>
        """
        let expected = [
            Thing(attribute: nil, value: ""),
            Thing(attribute: "x", value: ""),
            Thing(attribute: nil, value: ""),
        ]
        let result = try XMLDecoder().decode([Thing].self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }

    func testNestedEmptyElementEmptyStringDecoding() throws {
        let xml = """
        <parent>
            <thing/>
        </parent>
        """
        let expected = Parent(thing: Thing(attribute: nil, value: ""))
        let result = try XMLDecoder().decode(Parent.self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }
}
