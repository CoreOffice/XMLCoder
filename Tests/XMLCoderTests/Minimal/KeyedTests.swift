//
//  KeyedTests.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 19/11/2018.
//

import XCTest
@testable import XMLCoder

class KeyedTests: XCTestCase {
    struct Container: Codable, Equatable {
        let value: [String: Int]
    }

    struct ContainerCamelCase: Codable, Equatable {
        let valUe: [String: Int]
        let testAttribute: String
    }

    struct AnyKey: CodingKey {
        var stringValue: String
        var intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
            intValue = nil
        }

        init?(intValue: Int) {
            stringValue = String(intValue)
            self.intValue = intValue
        }
    }

    func testEmpty() throws {
        let decoder = XMLDecoder()

        let xmlString = "<container />"
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(Container.self, from: xmlData)
        XCTAssertEqual(decoded.value, [:])
    }

    func testSingleElement() throws {
        let decoder = XMLDecoder()

        let xmlString =
            """
            <container>
                <value>
                    <foo>12</foo>
                </value>
            </container>
            """
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(Container.self, from: xmlData)
        XCTAssertEqual(decoded.value, ["foo": 12])
    }

    func testMultiElement() throws {
        let decoder = XMLDecoder()

        let xmlString =
            """
            <container>
                <value>
                    <foo>12</foo>
                    <bar>34</bar>
                </value>
            </container>
            """
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(Container.self, from: xmlData)
        XCTAssertEqual(decoded.value, ["foo": 12, "bar": 34])
    }

    func testAttribute() {
        let encoder = XMLEncoder()

        encoder.nodeEncodingStrategy = .custom { _, _ in
            { _ in .attribute }
        }

        let container = Container(value: ["foo": 12, "bar": 34])

        XCTAssertThrowsError(
            try encoder.encode(container, withRootKey: "container")
        )
    }

    func testConvertFromSnakeCase() throws {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let xmlString =
            """
            <cont_ainer test_attribute="test_container">
                <val_ue>
                    <fo_o>12</fo_o>
                </val_ue>
            </cont_ainer>
            """
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(ContainerCamelCase.self, from: xmlData)

        XCTAssertEqual(decoded.valUe, ["foO": 12])
    }

    func testErrorDescriptionConvertFromSnakeCase() throws {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let xmlString =
            """
            <cont_aine test_attribut="test_container">
                <val_u>
                    <fo_oo>12</fo_oo>
                </val_u>
            </cont_aine>
            """
        let xmlData = xmlString.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(ContainerCamelCase.self, from: xmlData))
    }

    func testCustomDecoderConvert() throws {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .custom { keys in
            let lastComponent = keys.last!.stringValue.split(separator: "_").last!
            return AnyKey(stringValue: String(lastComponent))!
        }

        let xmlString =
            """
            <container testAttribute="test_container">
                <test_valUe>
                    <foo>12</foo>
                </test_valUe>
            </container>
            """
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(ContainerCamelCase.self, from: xmlData)

        XCTAssertEqual(decoded.valUe, ["foo": 12])
    }

    static var allTests = [
        ("testEmpty", testEmpty),
        ("testSingleElement", testSingleElement),
        ("testMultiElement", testMultiElement),
        ("testAttribute", testAttribute),
        ("testConvertFromSnakeCase", testConvertFromSnakeCase),
    ]
}
