// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Max Desiatov on 29/03/2019.
//

import Foundation
import XCTest
@testable import XMLCoder

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

    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
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
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "No coded value for string or int"
            ))
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
    func testEncode() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = []

        let foo1 = Foo2(number: [FooNumber(type: FooEnum.string("ABC")), FooNumber(type: FooEnum.int(123))])

        let header = XMLHeader(version: 1.0, encoding: "UTF-8")
        let encoded = try encoder.encode(foo1, withRootKey: "foo", header: header)
        let xmlString = String(data: encoded, encoding: .utf8)
        XCTAssertNotNil(xmlString)
        // Test string equivalency
        let encodedXML = xmlString!.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalXML = String(data: attributedEnumXML, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(encodedXML, originalXML)
    }

    // TODO: Fix decoding
    //    func testDecode() throws {
    //        let decoder = XMLDecoder()
    //        decoder.errorContextLength = 10
    //
    //        let foo = try decoder.decode(Foo2.self, from: attributedEnumXML)
    //        XCTAssertEqual(foo.number[0].type, FooEnum.string("ABC"))
    //        XCTAssertEqual(foo.number[1].type, FooEnum.int(123))
    //    }
}
