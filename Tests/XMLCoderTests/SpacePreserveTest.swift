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

private let copyrightXML = """
<t>Copyright © 2019 Company, Inc.</t>
""".data(using: .utf8)!

private let nestedCopyrightXML = """
<si><t>Copyright © 2019 Company, Inc.</t></si>
""".data(using: .utf8)!

private struct Item: Codable, Equatable {
    public let text: String?

    enum CodingKeys: String, CodingKey {
        case text = "t"
    }

    init(text: String?) {
        self.text = text
    }
}

final class SpacePreserveTest: XCTestCase {
    func testSimple() throws {
        let result = try XMLDecoder().decode(String.self, from: simpleXML)
        XCTAssertTrue(result.isEmpty)
    }

    func testSimpleOptional() throws {
        let result = try XMLDecoder().decode(String?.self, from: simpleXML)
        XCTAssertTrue(result?.isEmpty ?? false)
    }

    func testNestedOptional() throws {
        let result = try XMLDecoder().decode(Item.self, from: nestedXML)
        XCTAssertTrue(result.text?.isEmpty ?? false)
    }

    func testUntrimmed() throws {
        let result = try XMLDecoder(
            trimValueWhitespaces: false
        ).decode(String.self, from: simpleXML)
        XCTAssertFalse(result.isEmpty)

        let item = try XMLDecoder(
            trimValueWhitespaces: false
        ).decode(Item.self, from: nestedXML)
        XCTAssertFalse(item.text?.isEmpty ?? true)
    }

    func testCopyRight() throws {
        let decoder = XMLDecoder()
        decoder.trimValueWhitespaces = false
        let result = try decoder.decode(String.self, from: copyrightXML)
        XCTAssertEqual(result, "Copyright © 2019 Company, Inc.")

        let item = try decoder.decode(Item.self, from: nestedCopyrightXML)
        XCTAssertEqual(item, Item(text: "Copyright © 2019 Company, Inc."))

        XCTAssertEqual("Copyright © 2019 Company, Inc.".trimmingCharacters(in: .whitespacesAndNewlines), "Copyright © 2019 Company, Inc.")
    }
}
