//
//  NullTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/19/18.
//

import XCTest
@testable import XMLCoder

class NullTests: XCTestCase {
    struct Container: Codable, Equatable {
        let value: Int?
    }

    func testAttribute() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        encoder.nodeEncodingStrategy = .custom { _, _ in
            { _ in .attribute }
        }

        let xmlString =
            """
            <container />
            """
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(Container.self, from: xmlData)
        XCTAssertNil(decoded.value)

        let encoded = try encoder.encode(decoded, withRootKey: "container")
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
    }

    func testElement() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        encoder.outputFormatting = [.prettyPrinted]

        let xmlString =
            """
            <container />
            """
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(Container.self, from: xmlData)
        XCTAssertNil(decoded.value)

        let encoded = try encoder.encode(decoded, withRootKey: "container")
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
    }

    static var allTests = [
        ("testAttribute", testAttribute),
        ("testElement", testElement),
    ]
}
