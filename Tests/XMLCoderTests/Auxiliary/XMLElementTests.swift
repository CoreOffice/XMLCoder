// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Vincent Esche on 12/24/18.
//

import XCTest
@testable import XMLCoder

class XMLElementTests: XCTestCase {
    func testInitNull() {
        let null = XMLCoderElement(key: "foo")

        XCTAssertEqual(null.key, "foo")
        XCTAssertNil(null.stringValue)
        XCTAssertEqual(null.elements, [])
        XCTAssertEqual(null.attributes, [])
    }

    func testInitUnkeyed() {
        let keyed = XMLCoderElement(key: "foo", isStringBoxCDATA: false, box: UnkeyedBox())

        XCTAssertEqual(keyed.key, "foo")
        XCTAssertNil(keyed.stringValue)
        XCTAssertEqual(keyed.elements, [])
        XCTAssertEqual(keyed.attributes, [])
    }

    func testInitKeyed() {
        let keyed = XMLCoderElement(key: "foo", isStringBoxCDATA: false, box: KeyedBox(
            elements: [] as [(String, Box)],
            attributes: [("baz", NullBox()), ("blee", IntBox(42))] as [(String, SimpleBox)]
        ))

        XCTAssertEqual(keyed.key, "foo")
        XCTAssertNil(keyed.stringValue)
        XCTAssertEqual(keyed.elements, [])
        XCTAssertEqual(keyed.attributes, [XMLCoderElement.Attribute(key: "blee", value: "42")])
    }

    func testInitSimple() {
        let keyed = XMLCoderElement(key: "foo", isStringBoxCDATA: false, box: StringBox("bar"))
        let element = XMLCoderElement(stringValue: "bar")

        XCTAssertEqual(keyed.key, "foo")
        XCTAssertNil(keyed.stringValue)
        XCTAssertEqual(keyed.elements, [element])
        XCTAssertEqual(keyed.attributes, [])
    }
    
    func testWhitespaceWithNoElements_keyed() {
        let keyed = XMLCoderElement(key: "foo", isStringBoxCDATA: false, box: StringBox("bar"))
        XCTAssertFalse(keyed.isWhitespaceWithNoElements())
    }

    func testWhitespaceWithNoElements_whitespace() {
        let whitespaceElement1 = XMLCoderElement(stringValue: "\n    ")
        let whitespaceElement2 = XMLCoderElement(stringValue: "\n")
        let whitespaceElement3 = XMLCoderElement(stringValue: "    ")

        XCTAssert(whitespaceElement1.isWhitespaceWithNoElements())
        XCTAssert(whitespaceElement2.isWhitespaceWithNoElements())
        XCTAssert(whitespaceElement3.isWhitespaceWithNoElements())
    }

    func testNestedElementWith_Namespace_Attribute() {
        typealias Attribute = XMLCoderElement.Attribute
        typealias Element = XMLCoderElement
        let nested = Element(key: "Nested",
                             elements: [
                                Element(key: "",
                                        elements: [],
                                        attributes: [
                                            Attribute(key: "xsi:someName", value: "nestedAttrValue")
                                        ]
                                )],
                             attributes: [
                                Attribute(key: "xmlns:xsi", value: "https://example.com")
                             ])
        let simpleScalarPropertiesInputNamespace = Attribute(key: "xmlns", value: "https://example.com")
        let simpleScalarPropertiesInput = Element(key: "SimpleScalarPropertiesInput",
                                                  elements: [nested],
                                                  attributes: [simpleScalarPropertiesInputNamespace])

        let result = simpleScalarPropertiesInput.toXMLString(
            escapedCharacters: (elements: XMLEncoder().charactersEscapedInElements, attributes: XMLEncoder().charactersEscapedInAttributes),
            formatting: [],
            indentation: .spaces(4)
        )
        // swiftlint:disable line_length
        XCTAssertEqual(result, """
        <SimpleScalarPropertiesInput xmlns="https://example.com"><Nested xmlns:xsi="https://example.com" xsi:someName="nestedAttrValue"></Nested></SimpleScalarPropertiesInput>
        """)
    }

    func testNestedElementWith_Namespace_Attribute_Element() {
        typealias Attribute = XMLCoderElement.Attribute
        typealias Element = XMLCoderElement
        let nested = Element(key: "Nested",
                             elements: [
                                Element(key: "",
                                        elements: [
                                            Element(key: "nonAttrField",
                                                    elements: [Element(key: "", stringValue: "hello")],
                                                    attributes: [])
                                        ],
                                        attributes: [
                                            Attribute(key: "xsi:someName", value: "nestedAttrValue")
                                        ]
                                )],
                             attributes: [
                                Attribute(key: "xmlns:xsi", value: "https://example.com")
                             ])
        let simpleScalarPropertiesInputNamespace = Attribute(key: "xmlns", value: "https://example.com")
        let simpleScalarPropertiesInput = Element(key: "SimpleScalarPropertiesInput",
                                                  elements: [nested],
                                                  attributes: [simpleScalarPropertiesInputNamespace])

        let result = simpleScalarPropertiesInput.toXMLString(
            escapedCharacters: (elements: XMLEncoder().charactersEscapedInElements, attributes: XMLEncoder().charactersEscapedInAttributes),
            formatting: [],
            indentation: .spaces(4)
        )

        XCTAssertEqual(result, """
        <SimpleScalarPropertiesInput xmlns="https://example.com"><Nested xmlns:xsi="https://example.com" xsi:someName="nestedAttrValue"><nonAttrField>hello</nonAttrField></Nested></SimpleScalarPropertiesInput>
        """)
    }
}
