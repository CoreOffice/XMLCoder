//
//  AttributedIntrinsicTest.swift
//  XMLCoderTests
//
//  Created by Joseph Mattiello on 1/23/19.
//

import Foundation
import XCTest
@testable import XMLCoder

let fooXML = """
<?xml version="1.0" encoding="UTF-8"?>
<foo id="123">456</foo>
""".data(using: .utf8)!

private struct Foo: Codable, DynamicNodeEncoding {
    let id: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case id
        case value
    }

    static func nodeEncoding(forKey key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case CodingKeys.id:
            return .attribute
        default:
            return .element
        }
    }
}

private struct FooEmptyKeyed: Codable, DynamicNodeEncoding {
    let id: String
    let unkeyedValue: Int

    enum CodingKeys: String, CodingKey {
        case id
        case unkeyedValue = ""
    }

    static func nodeEncoding(forKey key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case CodingKeys.id:
            return .attribute
        default:
            return .element
        }
    }
}

final class AttributedIntrinsicTest: XCTestCase {

    func testEncode() {
        let encoder = XMLEncoder()
        encoder.outputFormatting = []

        let foo1 = FooEmptyKeyed(id: "123", unkeyedValue: 456)

        let header = XMLHeader(version: 1.0, encoding: "UTF-8")
        do {
            let encoded = try encoder.encode(foo1, withRootKey: "foo", header: header)
            let xmlString = String(data: encoded, encoding: .utf8)
            XCTAssertNotNil(xmlString)
            print(xmlString!)

            // Test string equivlancy
            let encodedXML = xmlString!.trimmingCharacters(in: .whitespacesAndNewlines)
            let originalXML = String(data: fooXML, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
            XCTAssertEqual(encodedXML, originalXML)
        } catch {
            print("Test threw error: " + error.localizedDescription)
            XCTFail(error.localizedDescription)
        }
    }

    func testDecode() {
        do {
            let decoder = XMLDecoder()
            decoder.errorContextLength = 10

            let foo1 = try decoder.decode(Foo.self, from: fooXML)
            XCTAssertEqual(foo1.id, "123")
            XCTAssertEqual(foo1.value, "456")

            let foo2 = try decoder.decode(FooEmptyKeyed.self, from: fooXML)
            XCTAssertEqual(foo2.id, "123")
            XCTAssertEqual(foo2.unkeyedValue, 456)
        } catch {
            print("Test threw error: " + error.localizedDescription)
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testEncode", testEncode),
        ("testDecode", testDecode),
        ]
}
