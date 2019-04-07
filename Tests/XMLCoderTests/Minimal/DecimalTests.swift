//
//  DecimalTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/19/18.
//

import XCTest
@testable import XMLCoder

class DecimalTests: XCTestCase {
    typealias Value = Decimal

    struct Container: Codable, Equatable {
        let value: Value
    }

    let values: [(Value, String)] = [
        (Decimal(-12.34), "-12.34"),
        (Decimal(0.0), "0"),
        (Decimal(12.34), "12.34"),
    ]

    func testMissing() {
        let decoder = XMLDecoder()

        let xmlString = "<container />"
        let xmlData = xmlString.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Container.self, from: xmlData))
    }

    func testAttribute() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        encoder.nodeEncodingStrategy = .custom { _, _ in
            { _ in .attribute }
        }

        for (value, xmlString) in values {
            let xmlString =
                """
                <container value="\(xmlString)" />
                """
            let xmlData = xmlString.data(using: .utf8)!

            let decoded = try decoder.decode(Container.self, from: xmlData)
            XCTAssertEqual(decoded.value, value)

            let encoded = try encoder.encode(decoded, withRootKey: "container")
            XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
        }
    }

    func testElement() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        encoder.outputFormatting = [.prettyPrinted]

        for (value, xmlString) in values {
            let xmlString =
                """
                <container>
                    <value>\(xmlString)</value>
                </container>
                """
            let xmlData = xmlString.data(using: .utf8)!

            let decoded = try decoder.decode(Container.self, from: xmlData)
            XCTAssertEqual(decoded.value, value)

            let encoded = try encoder.encode(decoded, withRootKey: "container")
            XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
        }
    }

    static var allTests = [
        ("testMissing", testMissing),
        ("testAttribute", testAttribute),
        ("testElement", testElement),
    ]
}
