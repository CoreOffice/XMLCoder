//
//  IntOrStringTest.swift
//  XMLCoderTests
//
//  Created by Benjamin Wetherfield on 7/4/19.
//

import XCTest
@testable import XMLCoder

let stringXML = """
<?xml version="1.0" encoding="UTF-8"?>
<container><string>forty-two</string></container>
""".data(using: .utf8)!

private struct IntOrStringContaining: Equatable, Codable {
    let element: IntOrString
    
    public func encode(to encoder: Encoder) throws {
        try element.encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        element = try IntOrString(from: decoder)
    }
    
    public init(element: IntOrString) {
        self.element = element
    }
}

private enum IntOrString: Equatable, Codable {
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

final class IntOrStringTest: XCTestCase {
    func testEncode() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = []
        
        let foo1 = IntOrStringContaining(element: IntOrString.string("forty-two"))
        
        let header = XMLHeader(version: 1.0, encoding: "UTF-8")
        let encoded = try encoder.encode(foo1, withRootKey: "container", header: header)
        let xmlString = String(data: encoded, encoding: .utf8)
        XCTAssertNotNil(xmlString)
        // Test string equivalency
        let encodedXML = xmlString!.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalXML = String(data: stringXML, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(encodedXML, originalXML)
    }
    
    static var allTests = [
        ("testEncode", testEncode),
    ]
}
