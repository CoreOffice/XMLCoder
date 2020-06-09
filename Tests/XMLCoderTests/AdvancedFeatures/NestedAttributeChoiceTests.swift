// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Benjamin Wetherfield on 7/23/19.
//

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

private struct Run: Codable, Equatable, DynamicNodeEncoding {
    let id: Int
    let text: String

    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case CodingKeys.id:
            return .attribute
        default:
            return .element
        }
    }
}

private struct Properties: Codable, Equatable, DynamicNodeEncoding {
    let id: Int
    let title: String

    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        return .attribute
    }
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

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self = .run(try container.decode(Run.self, forKey: .run))
        } catch {
            do {
                self = .properties(try container.decode(Properties.self, forKey: .properties))
            } catch {
                self = .br(try container.decode(Break.self, forKey: .br))
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .run(value):
            try container.encode(value, forKey: .run)
        case let .properties(value):
            try container.encode(value, forKey: .properties)
        case let .br(value):
            try container.encode(value, forKey: .br)
        }
    }
}

final class NestedAttributeChoiceTests: XCTestCase {
    private var encoder: XMLEncoder {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        return encoder
    }

    func testNestedEnumsEncoding() throws {
        let xml = """
        <container>
            <p>
                <br />
                <run id="1518">
                    <text>I am answering it again.</text>
                </run>
                <properties id="431" title="A Word About Wake Times" />
            </p>
            <p>
                <run id="1519">
                    <text>I am answering it again.</text>
                </run>
                <br />
            </p>
        </container>
        """
        let value = Container(
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
        let encoded = try encoder.encode(value, withRootKey: "container")
        XCTAssertEqual(String(data: encoded, encoding: .utf8), xml)
    }
}
