//
//  ElementNameTest.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 01/05/2019.
//

import XCTest
@testable import XMLCoder

private let nestedXML = """
<si><t xml:space="preserve"> </t></si>
""".data(using: .utf8)!

private struct Item: Codable, Equatable {
    let xmlElementName: String
    let text: String?

    enum CodingKeys: String, CodingKey {
        case xmlElementName
        case text = "t"
    }
}

final class ElementNameTest: XCTestCase {
    func testNested() throws {
        let result = try XMLDecoder().decode(Item.self, from: nestedXML)
        XCTAssertEqual(result.xmlElementName, "si")
    }
}
