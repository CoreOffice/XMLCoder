//
//  EnumAssociatedValueTestSimple.swift
//  XMLCoderTests
//
//  Created by James Bean on 7/9/19.
//

import XCTest
import XMLCoder

private enum IntOrString {
    case int(Int)
    case string(String)
}

extension IntOrString: Decodable {
    enum CodingKeys: String, CodingKey {
        case int
        case string
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

extension IntOrString: Equatable {}

class EnumAssociatedValuesTest: XCTestCase {
    func testIntOrStringIntDecoding() throws {
        let xml = "<int>42</int>"
        let result = try XMLDecoder().decode(IntOrString.self, from: xml.data(using: .utf8)!)
        let expected = IntOrString.int(42)
        XCTAssertEqual(result, expected)
    }

    func testIntOrStringStringDecoding() throws {
        let xml = "<string>forty-two</string>"
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
}
