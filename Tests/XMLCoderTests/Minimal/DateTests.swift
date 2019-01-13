//
//  DateTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/19/18.
//

import XCTest
@testable import XMLCoder

class DateTests: XCTestCase {
    typealias Value = Date

    struct Container: Codable, Equatable {
        let value: Value
    }

    let values: [(Value, String)] = [
        (Date(timeIntervalSince1970: 0.0), "0.0"),
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
            return { _ in .attribute }
        }

        encoder.dateEncodingStrategy = .secondsSince1970

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

        encoder.dateEncodingStrategy = .secondsSince1970

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

    func testKeyFormatedError() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        decoder.dateDecodingStrategy = .keyFormatted { _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "value"
            return formatter
        }

        encoder.outputFormatting = [.prettyPrinted]

        for (_, xmlString) in values {
            let xmlString =
                """
                <container>
                    <value>\(xmlString)</value>
                </container>
                """
            let xmlData = xmlString.data(using: .utf8)!

            XCTAssertThrowsError(try decoder.decode(Container.self, from: xmlData))
        }
    }

    func testKeyFormatedCouldNotDecodeError() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        decoder.dateDecodingStrategy = .keyFormatted { _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "value"
            return formatter
        }

        encoder.outputFormatting = [.prettyPrinted]

        for (_, xmlString) in values {
            let xmlString =
                """
                <container>
                <value>\(xmlString)</value>
                <value>\(xmlString)</value>
                </container>
                """
            let xmlData = xmlString.data(using: .utf8)!

            XCTAssertThrowsError(try decoder.decode(Container.self, from: xmlData))
        }
    }

    func testKeyFormatedNoPathError() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        decoder.dateDecodingStrategy = .keyFormatted { _ in
            let formatter = DateFormatter()
            formatter.dateFormat = "value"
            return formatter
        }

        encoder.outputFormatting = [.prettyPrinted]

        for (_, _) in values {
            let xmlString =
                """
                <container>
                    <value>12</value>
                </container>
                """
            let xmlData = xmlString.data(using: .utf8)!

            XCTAssertThrowsError(try decoder.decode(Container.self, from: xmlData))
        }
    }

    static var allTests = [
        ("testMissing", testMissing),
        ("testAttribute", testAttribute),
        ("testElement", testElement),
        ("testKeyFormatedError", testKeyFormatedError),
        ("testKeyFormatedCouldNotDecodeError", testKeyFormatedCouldNotDecodeError),
        ("testKeyFormatedNoPathError", testKeyFormatedNoPathError),
    ]
}
