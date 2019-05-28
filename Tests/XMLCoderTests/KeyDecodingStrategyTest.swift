//
//  KeyDecodingStrategyTest.swift
//  XMLCoder
//
//  Created by Max Desiatov on 02/05/2019.
//

import XCTest
@testable import XMLCoder

private let capitalized = """
<si><T>blah</T></si>
""".data(using: .utf8)!

private struct CapitalizedItem: Codable, Equatable {
    public let text: String

    enum CodingKeys: String, CodingKey {
        case text = "t"
    }
}

private let kebabCase = """
<si><tag-name>blah</tag-name></si>
""".data(using: .utf8)!

private struct KebabCaseItem: Codable, Equatable {
    public let text: String

    enum CodingKeys: String, CodingKey {
        case text = "tagName"
    }
}

final class KeyDecodingStrategyTest: XCTestCase {
    func testCapitalized() throws {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromCapitalized
        let decodedResult = try decoder.decode(CapitalizedItem.self, from: capitalized)
        XCTAssertEqual(decodedResult.text, "blah")

        let encoder = XMLEncoder()
        encoder.keyEncodingStrategy = .capitalized
        let encodedResult = try encoder.encode(decodedResult, withRootKey: "si")
        XCTAssertEqual(encodedResult, capitalized)
    }

    func testKebabCase() throws {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromKebabCase
        let decodedResult = try decoder.decode(KebabCaseItem.self, from: kebabCase)
        XCTAssertEqual(decodedResult.text, "blah")

        let encoder = XMLEncoder()
        encoder.keyEncodingStrategy = .convertToKebabCase
        let encodedResult = try encoder.encode(decodedResult, withRootKey: "si")
        XCTAssertEqual(encodedResult, kebabCase)
    }
}
