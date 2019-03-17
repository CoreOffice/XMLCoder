//
//  UnkeyedTests.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 19/11/2018.
//

import XCTest
@testable import XMLCoder

class UnkeyedTests: XCTestCase {
    struct Container: Codable, Equatable {
        let value: [String]
    }

    struct NilContainer: Codable, Equatable {
        let value: [String]?
    }

    struct NestedNilContainer: Codable, Equatable {
        let value: [String?]
    }

    struct NilOfNilsContainer: Codable, Equatable {
        let value: [String?]?
    }

    func testEmpty() throws {
        let decoder = XMLDecoder()

        let xmlString = "<container />"
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(Container.self, from: xmlData)
        XCTAssertEqual(decoded.value, [])
    }

    func testNil() throws {
        let decoder = XMLDecoder()

        let xmlString = "<container />"
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(NilContainer.self, from: xmlData)
        XCTAssertEqual(decoded.value, nil)
    }

    func testNilNil() throws {
        let decoder = XMLDecoder()

        let xmlString = "<container />"
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(NilOfNilsContainer.self,
                                         from: xmlData)
        XCTAssertEqual(decoded.value, nil)
    }

    func testNestedNilMultiElement() throws {
        let decoder = XMLDecoder()

        let xmlData = """
        <container>
            <value>test1</value>
            <value/>
            <value>test2</value>
        </container>
        """.data(using: .utf8)!

        let decoded = try decoder.decode(NestedNilContainer.self, from: xmlData)
        XCTAssertEqual(decoded.value, ["test1", nil, "test2"])
    }

    func testNestedNilSingleElement() throws {
        let decoder = XMLDecoder()

        let xmlData = """
        <container>
            <value/>
        </container>
        """.data(using: .utf8)!

        let decoded = try decoder.decode(NestedNilContainer.self, from: xmlData)
        XCTAssertEqual(decoded.value, [nil])
    }

    func testSingleElement() throws {
        let decoder = XMLDecoder()

        let xmlString =
            """
            <container>
            <value>foo</value>
            </container>
            """
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(Container.self, from: xmlData)
        XCTAssertEqual(decoded.value, ["foo"])
    }

    func testMultiElement() throws {
        let decoder = XMLDecoder()

        let xmlString =
            """
            <container>
                <value>foo</value>
                <value>bar</value>
            </container>
            """
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(Container.self, from: xmlData)
        XCTAssertEqual(decoded.value, ["foo", "bar"])
    }

    func testAttribute() {
        let encoder = XMLEncoder()

        encoder.nodeEncodingStrategy = .custom { _, _ in
            { _ in .attribute }
        }

        let container = Container(value: ["foo", "bar"])

        XCTAssertThrowsError(
            try encoder.encode(container, withRootKey: "container")
        )
    }

    static var allTests = [
        ("testEmpty", testEmpty),
        ("testSingleElement", testSingleElement),
        ("testMultiElement", testMultiElement),
        ("testAttribute", testAttribute),
    ]
}
