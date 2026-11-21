// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Vincent Esche on 12/21/18.
//

import XCTest
@testable import XMLCoder

class XMLStackParserTests: XCTestCase {
    func testParseWith() throws {
        let parser = XMLStackParser()

        let xmlString =
            """
            <container>
                <value>42</value>
                <data><![CDATA[lorem ipsum]]></data>
            </container>
            """
        let xmlData = xmlString.data(using: .utf8)!

        let root: XMLCoderElement? = try parser.parse(
            with: xmlData,
            errorContextLength: 0,
            shouldProcessNamespaces: false
        )

        let expected = XMLCoderElement(
            key: "container",
            elements: [
                XMLCoderElement(
                    key: "value",
                    stringValue: "42"
                ),
                XMLCoderElement(
                    key: "data",
                    cdataValue: "lorem ipsum"
                ),
            ]
        )
        XCTAssertEqual(root, expected)
    }

    func testParseWithThrow() throws {
        let parser = XMLStackParser()

        let xmlString = "lorem ipsum"
        let xmlData = xmlString.data(using: .utf8)!

        XCTAssertThrowsError(try parser.parse(
            with: xmlData,
            errorContextLength: 0,
            shouldProcessNamespaces: false
        ))
    }

    func testNestedMembers_removeWhitespaceElements() throws {
        let parser = XMLStackParser(trimValueWhitespaces: false, removeWhitespaceElements: true)
        let xmlData =
            """
            <SomeType>
                <nestedStringList>
                    <member>
                        <member>foo</member>
                        <member>bar</member>
                    </member>
                    <member>
                        <member>baz</member>
                        <member>qux</member>
                    </member>
                </nestedStringList>
            </SomeType>
            """.data(using: .utf8)!
        let root = try parser.parse(with: xmlData, errorContextLength: 0, shouldProcessNamespaces: false)

        XCTAssertEqual(root.elements[0].key, "nestedStringList")

        XCTAssertEqual(root.elements[0].elements[0].key, "member")
        XCTAssertEqual(root.elements[0].elements[0].elements[0].key, "member")
        XCTAssertEqual(root.elements[0].elements[0].elements[0].elements[0].stringValue, "foo")
        XCTAssertEqual(root.elements[0].elements[0].elements[1].elements[0].stringValue, "bar")

        XCTAssertEqual(root.elements[0].elements[1].key, "member")
        XCTAssertEqual(root.elements[0].elements[1].elements[0].key, "member")
        XCTAssertEqual(root.elements[0].elements[1].elements[0].elements[0].stringValue, "baz")
        XCTAssertEqual(root.elements[0].elements[1].elements[1].elements[0].stringValue, "qux")
    }

    func testNestedMembers() throws {
        let parser = XMLStackParser(trimValueWhitespaces: false, removeWhitespaceElements: false)
        let xmlData =
            """
            <SomeType>
                <nestedStringList>
                    <member>
                        <member>foo</member>
                        <member>bar</member>
                    </member>
                    <member>
                        <member>baz</member>
                        <member>qux</member>
                    </member>
                </nestedStringList>
            </SomeType>
            """.data(using: .utf8)!
        let root = try parser.parse(with: xmlData, errorContextLength: 0, shouldProcessNamespaces: false)

        XCTAssertEqual(root.elements[0].key, "")
        XCTAssertEqual(root.elements[0].stringValue, "\n    ")

        XCTAssertEqual(root.elements[1].key, "nestedStringList")
        XCTAssertEqual(root.elements[1].elements[0].key, "")
        XCTAssertEqual(root.elements[1].elements[0].stringValue, "\n        ")
        XCTAssertEqual(root.elements[1].elements[1].key, "member")
        XCTAssertEqual(root.elements[1].elements[1].elements[0].stringValue, "\n            ")

        XCTAssertEqual(root.elements[1].elements[1].elements[1].key, "member")
        XCTAssertEqual(root.elements[1].elements[1].elements[1].elements[0].stringValue, "foo")
        XCTAssertEqual(root.elements[1].elements[1].elements[3].key, "member")
        XCTAssertEqual(root.elements[1].elements[1].elements[3].elements[0].stringValue, "bar")

        XCTAssertEqual(root.elements[1].elements[3].elements[1].key, "member")
        XCTAssertEqual(root.elements[1].elements[3].elements[1].elements[0].stringValue, "baz")
        XCTAssertEqual(root.elements[1].elements[3].elements[3].key, "member")
        XCTAssertEqual(root.elements[1].elements[3].elements[3].elements[0].stringValue, "qux")
    }

    func testEscapableCharacters_removeWhitespaceElements() throws {
        let parser = XMLStackParser(trimValueWhitespaces: false, removeWhitespaceElements: true)
        let xmlData =
            """
            <SomeType>
                <strValue>escaped data: &amp;lt;&#xD;&#10;</strValue>
            </SomeType>
            """.data(using: .utf8)!
        let root = try parser.parse(with: xmlData, errorContextLength: 0, shouldProcessNamespaces: false)

        XCTAssertEqual(root.key, "SomeType")
        XCTAssertEqual(root.elements[0].key, "strValue")
        XCTAssertEqual(root.elements[0].elements[0].stringValue, "escaped data: &lt;\r\n")
    }

    func testEscapableCharacters() throws {
        let parser = XMLStackParser(trimValueWhitespaces: false, removeWhitespaceElements: false)
        let xmlData =
            """
            <SomeType>
                <strValue>escaped data: &amp;lt;&#xD;&#10;</strValue>
            </SomeType>
            """.data(using: .utf8)!
        let root = try parser.parse(with: xmlData, errorContextLength: 0, shouldProcessNamespaces: false)
        XCTAssertEqual(root.key, "SomeType")
        XCTAssertEqual(root.elements[0].key, "")
        XCTAssertEqual(root.elements[0].stringValue, "\n    ")
        XCTAssertEqual(root.elements[1].elements[0].stringValue, "escaped data: &lt;\r\n")
        XCTAssertEqual(root.elements[2].stringValue, "\n")
    }

    // libxml2 rejects a single input chunk larger than 10 MB unless
    // XML_PARSE_HUGE is set, so the parser must not receive all data at once.
    func testDecodeDocumentLargerThan10MB() throws {
        struct Catalog: Decodable {
            let item: [Item]
        }
        struct Item: Decodable, Equatable {
            let id: Int
            let name: String
        }

        let count = 100
        let name = String(repeating: "a", count: 110_000)
        var xmlString = "<catalog>"
        for i in 0..<count {
            xmlString += "<item><id>\(i)</id><name>\(name)</name></item>"
        }
        xmlString += "</catalog>"
        let xmlData = xmlString.data(using: .utf8)!
        XCTAssertGreaterThan(xmlData.count, 10_000_000)

        let catalog = try XMLDecoder().decode(Catalog.self, from: xmlData)
        XCTAssertEqual(catalog.item.count, count)
        XCTAssertEqual(catalog.item.last, Item(id: count - 1, name: name))
    }
}
