//
//  SpacePreserveTest.swift
//  XMLCoder
//
//  Created by Max Desiatov on 29/04/2019.
//

import XCTest
@testable import XMLCoder

private let simpleXML = """
<t xml:space="preserve"> </t>
""".data(using: .utf8)!

private let nestedXML = """
<si><t xml:space="preserve"> </t></si>
""".data(using: .utf8)!

private struct Item: Codable, Equatable {
    public let text: String?

    enum CodingKeys: String, CodingKey {
        case text = "t"
    }
}

final class SpacePreserveTest: XCTestCase {
    func testSimple() throws {
        let result = try XMLDecoder().decode(String?.self, from: simpleXML)
        XCTAssertTrue(result?.isEmpty ?? false)
    }

    func testNested() throws {
        let result = try XMLDecoder().decode(Item.self, from: nestedXML)
        XCTAssertTrue(result.text?.isEmpty ?? false)
    }
}
