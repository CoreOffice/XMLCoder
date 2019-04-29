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
<sst><si><t xml:space="preserve"> </t></si></sst>
""".data(using: .utf8)!

public struct SharedStrings: Codable, Equatable {
    public struct Item: Codable, Equatable {
        public let text: String?

        enum CodingKeys: String, CodingKey {
            case text = "t"
        }
    }

    public let items: [Item]

    enum CodingKeys: String, CodingKey {
        case items = "si"
    }
}

final class SpacePreserveTest: XCTestCase {
    func testSimple() throws {
        let result = try XMLDecoder().decode(String?.self, from: simpleXML)
        XCTAssertNil(result)
    }

    func testNested() throws {
        let result = try XMLDecoder().decode(SharedStrings.self, from: nestedXML)
        XCTAssertNil(result)
    }
}
