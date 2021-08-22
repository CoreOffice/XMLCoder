// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
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

private let copyright = "Copyright © 2019 Company, Inc."

private let copyrightXML = """
<t>\(copyright)</t>
""".data(using: .utf8)!

private let nestedCopyrightXML = """
<si><t>\(copyright)</t></si>
""".data(using: .utf8)!

private let deCharacterString = "Stilles Örtchen"
private let deCharacterXML = """
<t>\(deCharacterString)</t>
""".data(using: .utf8)!

private let jaCharacterString = "Music 音楽"
private let jaCharacterXML = """
<t>\(jaCharacterString)</t>
""".data(using: .utf8)!

private let deCharacterXMLNested = """
<si><t xml:space="preserve">\(deCharacterString)</t></si>
""".data(using: .utf8)!

private let deCharacterXMLSpaced = """
<t>     \(deCharacterString)    </t>
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

    func testCopyright() throws {
        let decoder = XMLDecoder()
        decoder.trimValueWhitespaces = false
        let result = try decoder.decode(String.self, from: copyrightXML)
        XCTAssertEqual(result, copyright)

        let item = try decoder.decode(Item.self, from: nestedCopyrightXML)
        XCTAssertEqual(item, Item(text: copyright))
    }

    func testNonStandardCharacters() throws {
        let decoder = XMLDecoder()
        decoder.trimValueWhitespaces = true
        let resultGerman = try decoder.decode(String.self, from: deCharacterXML)
        XCTAssertEqual(resultGerman, deCharacterString)

        let resultJapanese = try decoder.decode(String.self, from: jaCharacterXML)
        XCTAssertEqual(resultJapanese, jaCharacterString)
    }

    func testNonStandardCharactersNested() throws {
        let decoder = XMLDecoder(trimValueWhitespaces: true)

        let resultGerman = try decoder.decode(Item.self, from: deCharacterXMLNested)

        XCTAssertEqual(resultGerman, Item(text: deCharacterString))
    }

    func testNonStandardCharactersSpaced() throws {
        let decoder = XMLDecoder(trimValueWhitespaces: false)

        let resultGerman = try decoder.decode(String.self, from: deCharacterXMLSpaced)

        XCTAssertEqual(resultGerman, "     \(deCharacterString)    ")
    }

}
