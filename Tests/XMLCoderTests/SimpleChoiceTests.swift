//
//  SimpleChoiceTests.swift
//  XMLCoderTests
//
//  Created by James Bean on 7/15/19.
//

import XCTest
import XMLCoder

private enum IntOrString: Equatable {
    case int(Int)
    case string(String)
}

private struct MixedIntOrStringFirst: Equatable {
    let intOrString: IntOrString
    let otherValue: String
}

extension MixedIntOrStringFirst: Encodable {
    enum CodingKeys: String, CodingKey {
        case otherValue = "other-value"
    }

    func encode(to encoder: Encoder) throws {
        try intOrString.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(otherValue, forKey: .otherValue)
    }
}

private struct MixedOtherFirst: Equatable {
    let intOrString: IntOrString
    let otherValue: String
}

extension MixedOtherFirst: Encodable {
    enum CodingKeys: String, CodingKey {
        case otherValue = "other-value"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(otherValue, forKey: .otherValue)
        try intOrString.encode(to: encoder)
    }
}

private struct MixedEitherSide {
    let leading: String
    let intOrString: IntOrString
    let trailing: String
}

extension MixedEitherSide: Encodable {
    enum CodingKeys: String, CodingKey {
        case leading
        case trailing
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(leading, forKey: .leading)
        try intOrString.encode(to: encoder)
        try container.encode(trailing, forKey: .trailing)
    }
}

extension IntOrString: Codable {
    enum CodingKeys: String, XMLChoiceCodingKey {
        case int
        case string
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .int(value):
            try container.encode(value, forKey: .int)
        case let .string(value):
            try container.encode(value, forKey: .string)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self = .int(try container.decode(Int.self, forKey: .int))
        } catch {
            self = .string(try container.decode(String.self, forKey: .string))
        }
    }
}

class SimpleChoiceTests: XCTestCase {
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

    func testMixedEncode() throws {
        let first = MixedIntOrStringFirst(intOrString: .int(4), otherValue: "other")
        let second = MixedOtherFirst(intOrString: .int(4), otherValue: "other")
        let flanked = MixedEitherSide(leading: "first", intOrString: .string("then"), trailing: "second")

        let firstEncoded = try XMLEncoder().encode(first, withRootKey: "container")
        let secondEncoded = try XMLEncoder().encode(second, withRootKey: "container")
        let flankedEncoded = try XMLEncoder().encode(flanked, withRootKey: "container")

        let firstExpectedXML = "<container><int>4</int><other-value>other</other-value></container>"
        let secondExpectedXML = "<container><other-value>other</other-value><int>4</int></container>"
        let flankedExpectedXML = "<container><leading>first</leading><string>then</string><trailing>second</trailing></container>"

        XCTAssertEqual(String(data: firstEncoded, encoding: .utf8), firstExpectedXML)
        XCTAssertEqual(String(data: secondEncoded, encoding: .utf8), secondExpectedXML)
        XCTAssertEqual(String(data: flankedEncoded, encoding: .utf8), flankedExpectedXML)
    }
}
