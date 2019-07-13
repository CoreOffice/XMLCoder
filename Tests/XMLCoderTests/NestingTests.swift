//
//  NestingTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/22/18.
//

import XCTest
@testable import XMLCoder

final class NestingTests: XCTestCase {
    var encoder: XMLEncoder {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        return encoder
    }

    var decoder: XMLDecoder {
        let decoder = XMLDecoder()
        return decoder
    }

    let unkeyedWithinUnkeyed: [[Int]] = [
        [1, 2, 3],
        [1, 2, 3],
    ]

    let unkeyedWithinKeyed: [String: [Int]] = [
        "first": [1, 2, 3],
        "second": [1, 2, 3],
    ]

    let keyedWithinUnkeyed: [[String: Int]] = [
        ["first": 1],
        ["second": 2],
    ]

    let keyedWithinKeyed: [String: [String: Int]] = [
        "first": ["a": 1, "b": 2],
        "second": ["c": 3, "d": 4],
    ]

    func testEncodeUnkeyedWithinUnkeyed() throws {
        XCTAssertNoThrow(try encoder.encode(unkeyedWithinUnkeyed, withRootKey: "element"))
    }

    func testEncodeUnkeyedWithinKeyed() throws {
        XCTAssertNoThrow(try encoder.encode(unkeyedWithinKeyed, withRootKey: "element"))
    }

    func testEncodeKeyedWithinUnkeyed() throws {
        XCTAssertNoThrow(try encoder.encode(keyedWithinUnkeyed, withRootKey: "element"))
    }

    func testEncodeKeyedWithinKeyed() throws {
        XCTAssertNoThrow(try encoder.encode(keyedWithinKeyed, withRootKey: "element"))
    }

    func testDecodeUnkeyedWithinUnkeyed() throws {
        let xml =
            """
            <element>
                <element>
                    <element>1</element>
                    <element>2</element>
                    <element>3</element>
                </element>
                <element>
                    <element>1</element>
                    <element>2</element>
                    <element>3</element>
                </element>
            </element>
            """
        let encoded = xml.data(using: .utf8)!

        XCTAssertNoThrow(try decoder.decode(type(of: unkeyedWithinUnkeyed), from: encoded))
    }

    func testDecodeUnkeyedWithinKeyed() throws {
        let xml =
            """
            <element>
                <first>1</first>
                <first>2</first>
                <first>3</first>
                <second>1</second>
                <second>2</second>
                <second>3</second>
            </element>
            """
        let encoded = xml.data(using: .utf8)!

        XCTAssertNoThrow(try decoder.decode(type(of: unkeyedWithinKeyed), from: encoded))
    }

    func testDecodeKeyedWithinUnkeyed() throws {
        let xml =
            """
            <element>
                <element>
                    <first>1</first>
                </element>
                <element>
                    <second>2</second>
                </element>
            </element>
            """
        let encoded = xml.data(using: .utf8)!

        XCTAssertNoThrow(try decoder.decode(type(of: keyedWithinUnkeyed), from: encoded))
    }

    func testDecodeKeyedWithinKeyed() throws {
        let xml =
            """
            <element>
                <first>
                    <b>2</b>
                    <a>1</a>
                </first>
                <second>
                    <c>3</c>
                    <d>4</d>
                </second>
            </element>
            """
        let encoded = xml.data(using: .utf8)!

        XCTAssertNoThrow(try decoder.decode(type(of: keyedWithinKeyed), from: encoded))
    }

    static var allTests = [
        ("testEncodeUnkeyedWithinUnkeyed", testEncodeUnkeyedWithinUnkeyed),
        ("testEncodeUnkeyedWithinKeyed", testEncodeUnkeyedWithinKeyed),
        ("testEncodeKeyedWithinUnkeyed", testEncodeKeyedWithinUnkeyed),
        ("testEncodeKeyedWithinKeyed", testEncodeKeyedWithinKeyed),
        ("testDecodeUnkeyedWithinUnkeyed", testDecodeUnkeyedWithinUnkeyed),
        ("testDecodeUnkeyedWithinKeyed", testDecodeUnkeyedWithinKeyed),
        ("testDecodeKeyedWithinUnkeyed", testDecodeKeyedWithinUnkeyed),
        ("testDecodeKeyedWithinKeyed", testDecodeKeyedWithinKeyed),
    ]
}
