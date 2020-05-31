// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
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

    let xmlUnkeyedWithinUnkeyed =
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

    let unkeyedWithinKeyed: [String: [Int]] = [
        "first": [1, 2, 3],
        "second": [1, 2, 3],
    ]

    let xmlUnkeyedWithinKeyed =
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

    let keyedWithinUnkeyed: [[String: Int]] = [
        ["first": 1],
        ["second": 2],
    ]

    let xmlKeyedWithinUnkeyed =
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

    let keyedWithinKeyed: [String: [String: Int]] = [
        "first": ["a": 1, "b": 2],
        "second": ["c": 3, "d": 4],
    ]

    let xmlKeyedWithinKeyed =
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

    func testEncodeUnkeyedWithinUnkeyed() throws {
        let encoded = try encoder.encode(unkeyedWithinUnkeyed, withRootKey: "element")
        XCTAssertEqual(String(data: encoded, encoding: .utf8), xmlUnkeyedWithinUnkeyed)
    }

    func testEncodeUnkeyedWithinKeyed() throws {
        let encoded = try encoder.encode(unkeyedWithinKeyed, withRootKey: "element")
        let decoded = try decoder.decode([String: [Int]].self, from: encoded)
        XCTAssertEqual(decoded, unkeyedWithinKeyed)
    }

    func testEncodeKeyedWithinUnkeyed() throws {
        let encoded = try encoder.encode(keyedWithinUnkeyed, withRootKey: "element")
        XCTAssertEqual(String(data: encoded, encoding: .utf8), xmlKeyedWithinUnkeyed)
    }

    func testEncodeKeyedWithinKeyed() throws {
        let encoded = try encoder.encode(keyedWithinKeyed, withRootKey: "element")
        let decoded = try decoder.decode([String: [String: Int]].self, from: encoded)
        XCTAssertEqual(decoded, keyedWithinKeyed)
    }

    func testDecodeUnkeyedWithinUnkeyed() throws {
        let encoded = xmlUnkeyedWithinUnkeyed.data(using: .utf8)!
        let expected = unkeyedWithinUnkeyed
        let decoded = try decoder.decode([[Int]].self, from: encoded)
        XCTAssertEqual(decoded, expected)
    }

    func testDecodeUnkeyedWithinKeyed() throws {
        let encoded = xmlUnkeyedWithinKeyed.data(using: .utf8)!
        let expected = unkeyedWithinKeyed
        let decoded = try decoder.decode([String: [Int]].self, from: encoded)
        XCTAssertEqual(decoded, expected)
    }

    func testDecodeKeyedWithinUnkeyed() throws {
        let encoded = xmlKeyedWithinUnkeyed.data(using: .utf8)!
        let expected = keyedWithinUnkeyed
        let decoded = try decoder.decode([[String: Int]].self, from: encoded)
        XCTAssertEqual(decoded, expected)
    }

    func testDecodeKeyedWithinKeyed() throws {
        let encoded = xmlKeyedWithinKeyed.data(using: .utf8)!
        let expected = keyedWithinKeyed
        let decoded = try decoder.decode([String: [String: Int]].self, from: encoded)
        XCTAssertEqual(decoded, expected)
    }
}
