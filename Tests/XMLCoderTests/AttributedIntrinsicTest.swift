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

            // Test string equivalency
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

// MARK: - Enums

let attributedEnumXML = """
<?xml version="1.0" encoding="UTF-8"?>
<foo><number type="string">ABC</number><number type="int">123</number></foo>
""".data(using: .utf8)!

private struct Foo2: Codable {
    let number: [FooNumber]
}

private struct FooNumber: Codable, DynamicNodeEncoding {
    public let type: FooEnum

    public init(type: FooEnum) {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
        case typeValue = ""
    }

    public static func nodeEncoding(forKey key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case FooNumber.CodingKeys.type: return .attribute
        default: return .element
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        type = try container.decode(FooEnum.self, forKey: .type)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch type {
        case let .string(value):
            try container.encode("string", forKey: .type)
            try container.encode(value, forKey: .typeValue)
        case let .int(value):
            try container.encode("int", forKey: .type)
            try container.encode(value, forKey: .typeValue)
        }
    }
}

private enum FooEnum: Equatable, Codable {
    private enum CodingKeys: String, CodingKey {
        case string
        case int
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try values.decodeIfPresent(String.self, forKey: .string) {
            self = .string(value)
            return
        } else if let value = try values.decodeIfPresent(Int.self, forKey: .int) {
            self = .int(value)
            return
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath,
                                                                    debugDescription: "No coded value for string or int"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .string(value):
            try container.encode(value, forKey: .string)
        case let .int(value):
            try container.encode(value, forKey: .int)
        }
    }

    case string(String)
    case int(Int)
}

final class AttributedEnumIntrinsicTest: XCTestCase {
    func testEncode() {
        let encoder = XMLEncoder()
        encoder.outputFormatting = []

        let foo1 = Foo2(number: [FooNumber(type: FooEnum.string("ABC")), FooNumber(type: FooEnum.int(123))])

        let header = XMLHeader(version: 1.0, encoding: "UTF-8")
        do {
            let encoded = try encoder.encode(foo1, withRootKey: "foo", header: header)
            let xmlString = String(data: encoded, encoding: .utf8)
            XCTAssertNotNil(xmlString)
            print(xmlString!)

            // Test string equivalency
            let encodedXML = xmlString!.trimmingCharacters(in: .whitespacesAndNewlines)
            let originalXML = String(data: attributedEnumXML, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
            XCTAssertEqual(encodedXML, originalXML)
        } catch {
            print("Test threw error: " + error.localizedDescription)
            XCTFail(error.localizedDescription)
        }
    }

    // TODO: Fix decoding
//    func testDecode() {
//        do {
//            let decoder = XMLDecoder()
//            decoder.errorContextLength = 10
//
//            let foo = try decoder.decode(Foo2.self, from: attributedEnumXML)
//            XCTAssertEqual(foo.number[0].type, FooEnum.string("ABC"))
//            XCTAssertEqual(foo.number[1].type, FooEnum.int(123))
//        } catch {
//            print("Test threw error: " + error.localizedDescription)
//            XCTFail(error.localizedDescription)
//        }
//    }

    static var allTests = [
        ("testEncode", testEncode),
//        ("testDecode", testDecode),
    ]
}
