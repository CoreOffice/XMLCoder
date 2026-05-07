// Copyright (c) 2019-2023 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Alkenso (Vladimir Vashurkin) on 12.05.2023.
//

#if swift(>=5.5)

import Foundation
import XCTest
@testable import XMLCoder

private enum InlineChoice: Equatable, Codable {
    case simple(Nested1)
    case nested(Nested1, labeled: Nested2)
    case attributesOnly(AttributesOnly)

    enum CodingKeys: String, CodingKey, XMLChoiceCodingKey {
        case simple, nested, attributesOnly
    }

    enum SimpleCodingKeys: String, CodingKey { case _0 = "" }

    enum NestedCodingKeys: String, CodingKey {
        case _0 = ""
        case labeled
    }

    enum AttributesOnlyCodingKeys: String, CodingKey { case _0 = "" }

    struct Nested1: Equatable, Codable, DynamicNodeEncoding {
        var attr = "n1_a1"
        var val = "n1_v1"

        public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
            switch key {
            case CodingKeys.attr: return .attribute
            default: return .element
            }
        }
    }

    struct Nested2: Equatable, Codable {
        var val = "n2_val"
    }

    struct AttributesOnly: Equatable, Codable, DynamicNodeEncoding {
        var name = "attr"

        enum CodingKeys: String, CodingKey {
            case name = "Name"
        }

        public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
            return .attribute
        }
    }
}

final class InlinePropertyTests: XCTestCase {
    func testInlineChoiceOutput() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.prettyPrintIndentation = .spaces(4)
        
        let original = InlineChoice.nested(.init(), labeled: .init())
        let encoded = try encoder.encode(original, withRootKey: "container")
        XCTAssertEqual(
            String(data: encoded, encoding: .utf8),
            """
            <container>
                <nested attr="n1_a1">
                    <val>n1_v1</val>
                    <labeled>
                        <val>n2_val</val>
                    </labeled>
                </nested>
            </container>
            """
        )
        
        let decoded = try XMLDecoder().decode(InlineChoice.self, from: encoded)
        XCTAssertEqual(original, decoded)
    }
    
    func testArrayWithInlines() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.prettyPrintIndentation = .spaces(4)
        
        let original: [InlineChoice] = [
            .nested(.init(), labeled: .init()),
            .simple(.init()),
            .attributesOnly(.init())
        ]
        let encoded = try encoder.encode(original, withRootKey: "container")
        XCTAssertEqual(
            String(data: encoded, encoding: .utf8),
            """
            <container>
                <nested attr="n1_a1">
                    <val>n1_v1</val>
                    <labeled>
                        <val>n2_val</val>
                    </labeled>
                </nested>
                <simple attr="n1_a1">
                    <val>n1_v1</val>
                </simple>
                <attributesOnly Name="attr" />
            </container>
            """
        )
        
        let decoded = try XMLDecoder().decode([InlineChoice].self, from: encoded)
        XCTAssertEqual(original, decoded)
    }
}

#endif
