//
//  MixedChoiceAndNonChoiceTests.swift
//  XMLCoderTests
//
//  Created by Benjamin Wetherfield on 11/24/19.
//

import XCTest
import XMLCoder

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

private struct TwoChoiceElements {
    let first: IntOrString
    let second: IntOrString
}

extension TwoChoiceElements: Encodable {
    func encode(to encoder: Encoder) throws {
        try first.encode(to: encoder)
        try second.encode(to: encoder)
    }
}

class MixedChoiceAndNonChoiceTests: XCTestCase {
    func testMixedChoiceFirstEncode() throws {
        let first = MixedIntOrStringFirst(intOrString: .int(4), otherValue: "other")
        let firstEncoded = try XMLEncoder().encode(first, withRootKey: "container")
        let firstExpectedXML = "<container><int>4</int><other-value>other</other-value></container>"
        XCTAssertEqual(String(data: firstEncoded, encoding: .utf8), firstExpectedXML)
    }

    func testMixedChoiceSecondEncode() throws {
        let second = MixedOtherFirst(intOrString: .int(4), otherValue: "other")
        let secondEncoded = try XMLEncoder().encode(second, withRootKey: "container")
        let secondExpectedXML = "<container><other-value>other</other-value><int>4</int></container>"
        XCTAssertEqual(String(data: secondEncoded, encoding: .utf8), secondExpectedXML)
    }

    func testMixedChoiceFlankedEncode() throws {
        let flanked = MixedEitherSide(leading: "first", intOrString: .string("then"), trailing: "second")
        let flankedEncoded = try XMLEncoder().encode(flanked, withRootKey: "container")
        let flankedExpectedXML = """
        <container><leading>first</leading><string>then</string><trailing>second</trailing></container>
        """
        XCTAssertEqual(String(data: flankedEncoded, encoding: .utf8), flankedExpectedXML)
    }

    func testTwoChoiceElementsEncode() throws {
        let twoChoiceElements = TwoChoiceElements(first: .int(1), second: .string("one"))
        let encoded = try XMLEncoder().encode(twoChoiceElements, withRootKey: "container")
        let expectedXML = "<container><int>1</int><string>one</string></container>"
        XCTAssertEqual(String(data: encoded, encoding: .utf8), expectedXML)
    }
}
