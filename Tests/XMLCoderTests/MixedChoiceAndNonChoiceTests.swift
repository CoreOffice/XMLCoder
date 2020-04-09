//
//  MixedChoiceAndNonChoiceTests.swift
//  XMLCoderTests
//
//  Created by Benjamin Wetherfield on 11/24/19.
//

import XCTest
import XMLCoder

private enum AlternateIntOrString: Equatable {
    case alternateInt(Int)
    case alternateString(String)
}

extension AlternateIntOrString: Codable {
    enum CodingKeys: String, CodingKey {
        case alternateInt = "alternate-int"
        case alternateString = "alternate-string"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .alternateInt(int):
            try container.encode(int, forKey: .alternateInt)
        case let .alternateString(string):
            try container.encode(string, forKey: .alternateString)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.alternateInt) {
            self = .alternateInt(try container.decode(Int.self, forKey: .alternateInt))
        } else {
            self = .alternateString(try container.decode(String.self, forKey: .alternateString))
        }
    }
}

extension AlternateIntOrString.CodingKeys: XMLChoiceCodingKey {}

private struct MixedIntOrStringFirst: Equatable {
    let intOrString: IntOrString
    let otherValue: String
}

extension MixedIntOrStringFirst: Codable {
    enum CodingKeys: String, CodingKey {
        case otherValue = "other-value"
    }

    func encode(to encoder: Encoder) throws {
        try intOrString.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(otherValue, forKey: .otherValue)
    }

    init(from decoder: Decoder) throws {
        intOrString = try IntOrString(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        otherValue = try container.decode(String.self, forKey: .otherValue)
    }
}

private struct MixedOtherFirst: Equatable {
    let intOrString: IntOrString
    let otherValue: String
}

extension MixedOtherFirst: Codable {
    enum CodingKeys: String, CodingKey {
        case otherValue = "other-value"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(otherValue, forKey: .otherValue)
        try intOrString.encode(to: encoder)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        otherValue = try container.decode(String.self, forKey: .otherValue)
        intOrString = try IntOrString(from: decoder)
    }
}

private struct MixedEitherSide: Equatable {
    let leading: String
    let intOrString: IntOrString
    let trailing: String
}

extension MixedEitherSide: Codable {
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        leading = try container.decode(String.self, forKey: .leading)
        intOrString = try IntOrString(from: decoder)
        trailing = try container.decode(String.self, forKey: .trailing)
    }
}

private struct TwoChoiceElements: Equatable {
    let first: IntOrString
    let second: AlternateIntOrString
}

extension TwoChoiceElements: Codable {
    func encode(to encoder: Encoder) throws {
        try first.encode(to: encoder)
        try second.encode(to: encoder)
    }

    init(from decoder: Decoder) throws {
        first = try IntOrString(from: decoder)
        second = try AlternateIntOrString(from: decoder)
    }
}

final class MixedChoiceAndNonChoiceTests: XCTestCase {
    func testMixedChoiceFirstEncode() throws {
        let first = MixedIntOrStringFirst(intOrString: .int(4), otherValue: "other")
        let firstEncoded = try XMLEncoder().encode(first, withRootKey: "container")
        let firstExpectedXML = "<container><int>4</int><other-value>other</other-value></container>"
        XCTAssertEqual(String(data: firstEncoded, encoding: .utf8), firstExpectedXML)
    }

    func testMixedChoiceFirstDecode() throws {
        let xmlString = "<container><int>4</int><other-value>other</other-value></container>"
        let xmlData = xmlString.data(using: .utf8)!
        let decoded = try XMLDecoder().decode(MixedIntOrStringFirst.self, from: xmlData)
        let expected = MixedIntOrStringFirst(intOrString: .int(4), otherValue: "other")
        XCTAssertEqual(decoded, expected)
    }

    func testMixedChoiceSecondEncode() throws {
        let second = MixedOtherFirst(intOrString: .int(4), otherValue: "other")
        let secondEncoded = try XMLEncoder().encode(second, withRootKey: "container")
        let secondExpectedXML = "<container><other-value>other</other-value><int>4</int></container>"
        XCTAssertEqual(String(data: secondEncoded, encoding: .utf8), secondExpectedXML)
    }

    func testMixedChoiceSecondDecode() throws {
        let xmlString = "<container><other-value>other</other-value><int>4</int></container>"
        let xmlData = xmlString.data(using: .utf8)!
        let decoded = try XMLDecoder().decode(MixedOtherFirst.self, from: xmlData)
        let expected = MixedOtherFirst(intOrString: .int(4), otherValue: "other")
        XCTAssertEqual(decoded, expected)
    }

    func testMixedChoiceFlankedEncode() throws {
        let flanked = MixedEitherSide(leading: "first", intOrString: .string("then"), trailing: "second")
        let flankedEncoded = try XMLEncoder().encode(flanked, withRootKey: "container")
        let flankedExpectedXML = """
        <container><leading>first</leading><string>then</string><trailing>second</trailing></container>
        """
        XCTAssertEqual(String(data: flankedEncoded, encoding: .utf8), flankedExpectedXML)
    }

    func testMixedChoiceFlankedDecode() throws {
        let xmlString = """
        <container><leading>first</leading><string>then</string><trailing>second</trailing></container>
        """
        let xmlData = xmlString.data(using: .utf8)!
        let decoded = try XMLDecoder().decode(MixedEitherSide.self, from: xmlData)
        let expected = MixedEitherSide(leading: "first", intOrString: .string("then"), trailing: "second")
        XCTAssertEqual(decoded, expected)
    }

    func testTwoChoiceElementsEncode() throws {
        let twoChoiceElements = TwoChoiceElements(first: .int(1), second: .alternateString("one"))
        let encoded = try XMLEncoder().encode(twoChoiceElements, withRootKey: "container")
        let expectedXML = "<container><int>1</int><alternate-string>one</alternate-string></container>"
        XCTAssertEqual(String(data: encoded, encoding: .utf8), expectedXML)
    }

    func testTwoChoiceElementsDecode() throws {
        let xmlString = "<container><int>1</int><alternate-string>one</alternate-string></container>"
        let xmlData = xmlString.data(using: .utf8)!
        let decoded = try XMLDecoder().decode(TwoChoiceElements.self, from: xmlData)
        let expected = TwoChoiceElements(first: .int(1), second: .alternateString("one"))
        XCTAssertEqual(decoded, expected)
    }
}
