// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Christopher Williams on 11/21/19.
//

import Foundation

import XCTest
@testable import XMLCoder

class MixedContentTests: XCTestCase {
    enum TextItem: Codable, Equatable {
        case bold(String)
        case text(String)

        enum CodingKeys: String, XMLChoiceCodingKey {
            case bold = "b"
            case text = ""
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case let .text(text):
                try container.encode(text, forKey: .text)
            case let .bold(text):
                try container.encode(text, forKey: .bold)
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let key = container.allKeys.first!
            switch key {
            case .bold:
                let string = try container.decode(String.self, forKey: .bold)
                self = .bold(string)
            case .text:
                let string = try container.decode(String.self, forKey: .text)
                self = .text(string)
            }
        }
    }

    func testMixed() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        let xmlString =
            """
            <container>first<b>bold text</b>second</container>
            """

        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode([TextItem].self, from: xmlData)
        XCTAssertEqual(decoded, [.text("first"), .bold("bold text"), .text("second")])

        let encoded = try encoder.encode(decoded, withRootKey: "container")
        let encodedString = String(data: encoded, encoding: .utf8)
        XCTAssertEqual(encodedString, xmlString)
    }
}
