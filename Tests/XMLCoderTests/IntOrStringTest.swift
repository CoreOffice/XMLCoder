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
let intXML = """
<?xml version="1.0" encoding="UTF-8"?>
<container><int>42</int></container>
""".data(using: .utf8)!

let explicitXML = """
<?xml version="1.0" encoding="UTF-8"?>
<container><intOrString><int>42</int></intOrString><intOrString><string>forty-two</string></intOrString></container>
""".data(using: .utf8)!

private struct IntOrStringArray: Equatable, Codable {
    let element: [IntOrString]
    
    enum CodingKeys: String, CodingKey {
        case element = ""
    }
}

private struct IntOrStringExplicitArray: Equatable, Codable {
    let intOrString: [IntOrString]
}

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

    private let string = IntOrStringContaining(element: IntOrString.string("forty-two"))
    private let int = IntOrStringContaining(element: IntOrString.int(42))
    private let array = IntOrStringArray(element: [.string("forty-two"), .int(42)])
    
    func testEncode() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = []
        
        let header = XMLHeader(version: 1.0, encoding: "UTF-8")
        let encodedString = try encoder.encode(string, withRootKey: "container", header: header)
        let encodedInt = try encoder.encode(int, withRootKey: "container", header: header)
        let stringXMLString = String(data: encodedString, encoding: .utf8)
        let intXMLString = String(data: encodedInt, encoding: .utf8)

        // Test string equivalency
        let encodedStringXML = stringXMLString!.trimmingCharacters(in: .whitespacesAndNewlines)
        let encodedIntXML = intXMLString!.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalStringXML = String(data: stringXML, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalIntXML = String(data: intXML, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(encodedStringXML, originalStringXML)
        XCTAssertEqual(encodedIntXML, originalIntXML)
    }
    
    func testDecode() throws {
        let decoder = XMLDecoder()
        let decodedString = try decoder.decode(IntOrStringContaining.self, from: stringXML)
        let decodedInt = try decoder.decode(IntOrStringContaining.self, from: intXML)
        XCTAssertEqual(string, decodedString)
        XCTAssertEqual(int, decodedInt)
    }
    
    func testEncodeExplicitArray() throws {
        let encoder = XMLEncoder()
        
        let explicitArray = IntOrStringExplicitArray(intOrString: [
            IntOrString.int(42),
            IntOrString.string("forty-two")
            ])
        
        let header = XMLHeader(version: 1.0, encoding: "UTF-8")
        let encodedArray = try encoder.encode(explicitArray, withRootKey: "container", header: header)

        let arrayXMLString = String(data: encodedArray, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        XCTAssertEqual(arrayXMLString, String(data: explicitXML, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testDecodeExplicitArray() throws {
        let decoder = XMLDecoder()
        let decodedExplicit = try decoder.decode(IntOrStringExplicitArray.self, from: explicitXML)
        print(decodedExplicit)
        
        let correct = IntOrStringExplicitArray(intOrString: [
            IntOrString.int(42),
            IntOrString.string("forty-two")
            ])
        
        XCTAssertEqual(correct, decodedExplicit)
    }
    
    func testNonExplicitArray() throws {
        let encoder = XMLEncoder()
        
        let header = XMLHeader(version: 1.0, encoding: "UTF-8")
        let encodedArray = try encoder.encode(array, withRootKey: "container", header: header)
        
        let arrayXMLString = String(data: encodedArray, encoding: .utf8)
        
        print(arrayXMLString)
        
        let decoder = XMLDecoder()
        let decodedStringArray = try decoder.decode(IntOrStringArray.self, from: stringXML)
        print(decodedStringArray)
    }
    
    static var allTests = [
        ("testEncode", testEncode),
        ("testDecode", testDecode),
        ("testEncodeExplicitArray", testEncodeExplicitArray),
        ("testDecodeExplicitArray", testDecodeExplicitArray),
        ("testNonExplicitArray", testNonExplicitArray)
    ]
}
