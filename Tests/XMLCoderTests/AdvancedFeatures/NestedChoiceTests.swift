// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by James Bean on 7/15/19.
//

#if swift(>=5.5)

import XCTest
import XMLCoder

private struct Container: Equatable {
    let paragraphs: [Paragraph]
}

private struct Paragraph: Equatable {
    let entries: [Entry]
}

private enum Entry: Equatable {
    case run(Run)
    case properties(Properties)
    case br(Break)
}

private struct Run: Codable, Equatable {
    let id: Int
    let text: String
}

private struct Properties: Codable, Equatable {
    let id: Int
    let title: String
}

private struct Break: Codable, Equatable {}

extension Container: Codable {
    enum CodingKeys: String, CodingKey {
        case paragraphs = "p"
    }
}

extension Paragraph: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        entries = try container.decode([Entry].self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(entries)
    }
}

extension Entry: Codable {
    private enum CodingKeys: String, XMLChoiceCodingKey {
        case run, properties, br
    }

    private enum RunCodingKeys: String, CodingKey { case _0 = "" }
    private enum PropertiesCodingKeys: String, CodingKey { case _0 = "" }
    private enum BrCodingKeys: String, CodingKey { case _0 = "" }
}

final class NestedChoiceTests: XCTestCase {
    func testBreakDecoding() throws {
        let xml = "<br></br>"
        let result = try XMLDecoder().decode(Break.self, from: xml.data(using: .utf8)!)
        let expected = Break()
        XCTAssertEqual(result, expected)
    }

    func testPropertiesDecoding() throws {
        let xml = """
        <properties>
            <id>431</id>
            <title>A Word About Wake Times</title>
        </properties>
        """
        let result = try XMLDecoder().decode(Properties.self, from: xml.data(using: .utf8)!)
        let expected = Properties(id: 431, title: "A Word About Wake Times")
        XCTAssertEqual(result, expected)
    }

    func testPropertiesAsEntryDecoding() throws {
        let xml = """
        <entry>
            <properties>
                <id>431</id>
                <title>A Word About Wake Times</title>
            </properties>
        </entry>
        """
        let result = try XMLDecoder().decode(Entry.self, from: xml.data(using: .utf8)!)
        let expected: Entry = .properties(Properties(id: 431, title: "A Word About Wake Times"))
        XCTAssertEqual(result, expected)
    }

    func testRunDecoding() throws {
        let xml = """
        <run>
            <id>1518</id>
            <text>I am answering it again.</text>
        </run>
        """
        let result = try XMLDecoder().decode(Run.self, from: xml.data(using: .utf8)!)
        let expected = Run(id: 1518, text: "I am answering it again.")
        XCTAssertEqual(result, expected)
    }

    func testRunAsEntryDecoding() throws {
        let xml = """
        <entry>
            <run>
                <id>1518</id>
                <text>I am answering it again.</text>
            </run>
        </entry>
        """
        let result = try XMLDecoder().decode(Entry.self, from: xml.data(using: .utf8)!)
        let expected = Entry.run(Run(id: 1518, text: "I am answering it again."))
        XCTAssertEqual(result, expected)
    }

    func testEntriesDecoding() throws {
        let xml = """
        <entries>
            <run>
                <id>1518</id>
                <text>I am answering it again.</text>
            </run>
            <properties>
                <id>431</id>
                <title>A Word About Wake Times</title>
            </properties>
        </entries>
        """
        let result = try XMLDecoder().decode([Entry].self, from: xml.data(using: .utf8)!)
        let expected: [Entry] = [
            .run(Run(id: 1518, text: "I am answering it again.")),
            .properties(Properties(id: 431, title: "A Word About Wake Times")),
        ]
        XCTAssertEqual(result, expected)
    }

    func testParagraphDecoding() throws {
        let xml = """
        <p>
            <run>
                <id>1518</id>
                <text>I am answering it again.</text>
            </run>
            <properties>
                <id>431</id>
                <title>A Word About Wake Times</title>
            </properties>
        </p>
        """
        let result = try XMLDecoder().decode(Paragraph.self, from: xml.data(using: .utf8)!)
        let expected = Paragraph(
            entries: [
                .run(Run(id: 1518, text: "I am answering it again.")),
                .properties(Properties(id: 431, title: "A Word About Wake Times")),
            ]
        )
        XCTAssertEqual(result, expected)
    }

    func testNestedEnums() throws {
        let xml = """
        <container>
            <p>
                <run>
                    <id>1518</id>
                    <text>I am answering it again.</text>
                </run>
                <properties>
                    <id>431</id>
                    <title>A Word About Wake Times</title>
                </properties>
            </p>
            <p>
                <run>
                    <id>1519</id>
                    <text>I am answering it again.</text>
                </run>
            </p>
        </container>
        """
        let result = try XMLDecoder().decode(Container.self, from: xml.data(using: .utf8)!)
        let expected = Container(
            paragraphs: [
                Paragraph(
                    entries: [
                        .run(Run(id: 1518, text: "I am answering it again.")),
                        .properties(Properties(id: 431, title: "A Word About Wake Times")),
                    ]
                ),
                Paragraph(
                    entries: [
                        .run(Run(id: 1519, text: "I am answering it again.")),
                    ]
                ),
            ]
        )
        XCTAssertEqual(result, expected)
    }

    func testNestedEnumsWithEmptyStruct() throws {
        let xml = """
        <container>
            <p>
                <br></br>
                <run>
                    <id>1518</id>
                    <text>I am answering it again.</text>
                </run>
                <properties>
                    <id>431</id>
                    <title>A Word About Wake Times</title>
                </properties>
            </p>
            <p>
                <run>
                    <id>1519</id>
                    <text>I am answering it again.</text>
                </run>
                <br />
            </p>
        </container>
        """
        let result = try XMLDecoder().decode(Container.self, from: xml.data(using: .utf8)!)
        let expected = Container(
            paragraphs: [
                Paragraph(
                    entries: [
                        .br(Break()),
                        .run(Run(id: 1518, text: "I am answering it again.")),
                        .properties(Properties(id: 431, title: "A Word About Wake Times")),
                    ]
                ),
                Paragraph(
                    entries: [
                        .run(Run(id: 1519, text: "I am answering it again.")),
                        .br(Break()),
                    ]
                ),
            ]
        )
        XCTAssertEqual(result, expected)
    }

    func testNestedEnumsRoundTrip() throws {
        let original = Container(
            paragraphs: [
                Paragraph(
                    entries: [
                        .run(Run(id: 1518, text: "I am answering it again.")),
                        .properties(Properties(id: 431, title: "A Word About Wake Times")),
                    ]
                ),
                Paragraph(
                    entries: [
                        .run(Run(id: 1519, text: "I am answering it again.")),
                    ]
                ),
            ]
        )
        let encoded = try XMLEncoder().encode(original, withRootKey: "container")
        let decoded = try XMLDecoder().decode(Container.self, from: encoded)
        XCTAssertEqual(decoded, original)
    }
}

#endif
