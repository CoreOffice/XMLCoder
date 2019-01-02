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
            return { _ in .attribute }
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
            <cont_ainer>
                <val_ue>
                    <fo_o>12</fo_o>
                </val_ue>
            </cont_ainer>
            """
        let xmlData = xmlString.data(using: .utf8)!
        
        let decoded = try decoder.decode(ContainerCamelCase.self, from: xmlData)
        
        XCTAssertEqual(decoded.valUe, ["foO": 12])
    }

    static var allTests = [
        ("testEmpty", testEmpty),
        ("testSingleElement", testSingleElement),
        ("testMultiElement", testMultiElement),
        ("testAttribute", testAttribute),
        ("testConvertFromSnakeCase", testConvertFromSnakeCase)
    ]
}
