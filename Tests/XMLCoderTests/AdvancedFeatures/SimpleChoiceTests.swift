// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by James Bean on 7/15/19.
//

import XCTest
import XMLCoder

#if swift(>=5.5)
private enum InlineChoice: Equatable, Codable {
    case nested(Nested1, labeled: Nested2)
    
    enum NestedCodingKeys: String, CodingKey {
        case _0 = ""
        case labeled
    }
    
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
}
#endif

final class SimpleChoiceTests: XCTestCase {
    func testIntOrStringIntDecoding() throws {
        let xml = """
        <container>
            <int>42</int>
        </container>
        """
        let result = try XMLDecoder().decode(IntOrString.self, from: xml.data(using: .utf8)!)
        let expected = IntOrString.int(42)
        XCTAssertEqual(result, expected)
    }

    func testIntOrStringStringDecoding() throws {
        let xml = """
        <container>
            <string>forty-two</string>"
        </container>
        """
        let result = try XMLDecoder().decode(IntOrString.self, from: xml.data(using: .utf8)!)
        let expected = IntOrString.string("forty-two")
        XCTAssertEqual(result, expected)
    }

    func testIntOrStringArrayDecoding() throws {
        let xml = """
        <container>
            <int>1</int>
            <string>two</string>
            <string>three</string>
            <int>4</int>
            <int>5</int>
        </container>
        """
        let result = try XMLDecoder().decode([IntOrString].self, from: xml.data(using: .utf8)!)
        let expected: [IntOrString] = [
            .int(1),
            .string("two"),
            .string("three"),
            .int(4),
            .int(5),
        ]
        XCTAssertEqual(result, expected)
    }

    func testIntOrStringRoundTrip() throws {
        let original = IntOrString.int(5)
        let encoded = try XMLEncoder().encode(original, withRootKey: "container")
        let decoded = try XMLDecoder().decode(IntOrString.self, from: encoded)
        XCTAssertEqual(original, decoded)
    }

    func testIntOrStringArrayRoundTrip() throws {
        let original: [IntOrString] = [
            .int(1),
            .string("two"),
            .string("three"),
            .int(4),
            .int(5),
        ]
        let encoded = try XMLEncoder().encode(original, withRootKey: "container")
        let decoded = try XMLDecoder().decode([IntOrString].self, from: encoded)
        XCTAssertEqual(original, decoded)
    }

    func testIntOrStringDoubleArrayRoundTrip() throws {
        let original: [[IntOrString]] = [[
            .int(1),
            .string("two"),
            .string("three"),
            .int(4),
            .int(5),
        ]]
        let encoded = try XMLEncoder().encode(original, withRootKey: "container")
        let decoded = try XMLDecoder().decode([[IntOrString]].self, from: encoded)
        XCTAssertEqual(original, decoded)
    }
    
#if swift(>=5.5)
    func testMixedChoice() throws {
        enum Choice: Equatable, Codable {
            case one
            case two(value: Int)
            case three(key: String, value: Int)
            case four(Int)
        }

        struct Foo: Equatable, Codable {
            var field1 = Choice.one
            var field2 = Choice.two(value: 10)
            var field3 = Choice.three(key: "qq", value: 20)
            var field4 = Choice.four(30)
        }
        
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.prettyPrintIndentation = .spaces(4)
        
        let original = Foo()
        let encoded = try encoder.encode(original, withRootKey: "container")
        let decoded = try XMLDecoder().decode(Foo.self, from: encoded)
        XCTAssertEqual(original, decoded)
        
        XCTAssertEqual(
            String(data: encoded, encoding: .utf8),
            """
            <container>
                <field1>
                    <one />
                </field1>
                <field2>
                    <two>
                        <value>10</value>
                    </two>
                </field2>
                <field3>
                    <three>
                        <key>qq</key>
                        <value>20</value>
                    </three>
                </field3>
                <field4>
                    <four>
                        <_0>30</_0>
                    </four>
                </field4>
            </container>
            """
        )
    }

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
    }

    func testInlineChoiceDecoding() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.prettyPrintIndentation = .spaces(4)
        
        let original = InlineChoice.nested(.init(), labeled: .init())
        let encoded = try encoder.encode(original)
        let decoded = try XMLDecoder().decode(InlineChoice.self, from: encoded)
        XCTAssertEqual(original, decoded)
    }
#endif
}
