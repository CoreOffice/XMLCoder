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

private struct Item: Codable, Equatable {
    public let text: String

    enum CodingKeys: String, CodingKey {
        case text = "t"
    }
}

final class KeyDecodingStrategyTest: XCTestCase {
    func testCapitalized() throws {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromCapitalized
        let result = try decoder.decode(Item.self, from: capitalized)
        XCTAssertEqual(result.text, "blah")
    }
}
