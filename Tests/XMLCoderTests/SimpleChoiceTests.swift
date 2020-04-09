//
//  SimpleChoiceTests.swift
//  XMLCoderTests
//
//  Created by James Bean on 7/15/19.
//

import XCTest
import XMLCoder

final class SimpleChoiceTests: XCTestCase {
    func testIntOrStringIntDecoding() throws {
        let xml = """
        <container>
            <int>42</int>
        </container>
        """
        let result = try XMLDecoder().decode(IntOrString.self, from: xml.data(using: .utf8)!)
        let expected = IntOrString.int(42)
        XCTAssertEqual(result, expected)
    }

    func testIntOrStringStringDecoding() throws {
        let xml = """
        <container>
            <string>forty-two</string>"
        </container>
        """
        let result = try XMLDecoder().decode(IntOrString.self, from: xml.data(using: .utf8)!)
        let expected = IntOrString.string("forty-two")
        XCTAssertEqual(result, expected)
    }

    func testIntOrStringArrayDecoding() throws {
        let xml = """
        <container>
            <int>1</int>
            <string>two</string>
            <string>three</string>
            <int>4</int>
            <int>5</int>
        </container>
        """
        let result = try XMLDecoder().decode([IntOrString].self, from: xml.data(using: .utf8)!)
        let expected: [IntOrString] = [
            .int(1),
            .string("two"),
            .string("three"),
            .int(4),
            .int(5),
        ]
        XCTAssertEqual(result, expected)
    }

    func testIntOrStringRoundTrip() throws {
        let original = IntOrString.int(5)
        let encoded = try XMLEncoder().encode(original, withRootKey: "container")
        let decoded = try XMLDecoder().decode(IntOrString.self, from: encoded)
        XCTAssertEqual(original, decoded)
    }

    func testIntOrStringArrayRoundTrip() throws {
        let original: [IntOrString] = [
            .int(1),
            .string("two"),
            .string("three"),
            .int(4),
            .int(5),
        ]
        let encoded = try XMLEncoder().encode(original, withRootKey: "container")
        let decoded = try XMLDecoder().decode([IntOrString].self, from: encoded)
        XCTAssertEqual(original, decoded)
    }

    func testIntOrStringDoubleArrayRoundTrip() throws {
        let original: [[IntOrString]] = [[
            .int(1),
            .string("two"),
            .string("three"),
            .int(4),
            .int(5),
        ]]
        let encoded = try XMLEncoder().encode(original, withRootKey: "container")
        let decoded = try XMLDecoder().decode([[IntOrString]].self, from: encoded)
        XCTAssertEqual(original, decoded)
    }
}
