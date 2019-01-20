//
//  DataTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/19/18.
//

import XCTest
@testable import XMLCoder

class DataTests: XCTestCase {
    typealias Value = Data

    struct Container: Codable, Equatable {
        let value: Value
    }

    let values: [(Value, String)] = [
        // FIXME:
        // (Data(base64Encoded: "")!, ""),
        (Data(base64Encoded: "bG9yZW0gaXBzdW0=")!, "bG9yZW0gaXBzdW0="),
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

    func testStrategy() throws {
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

    func testKeyFormated() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        decoder.dataDecodingStrategy = .keyFormatted { $0.stringValue.data(using: .utf8) }

        encoder.outputFormatting = [.prettyPrinted]

        for (_, xmlString) in values {
            let xmlString =
                """
                <container>
                    <value>\(xmlString)</value>
                </container>
                """
            let xmlData = xmlString.data(using: .utf8)!

            let decoded = try decoder.decode(Container.self, from: xmlData)

            XCTAssertEqual(decoded.value, Data("value".utf8))
        }
    }

    func testKeyFormatedError() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        decoder.dataDecodingStrategy = .keyFormatted { codingKey in
            Data(base64Encoded: codingKey.stringValue)
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

        decoder.dataDecodingStrategy = .keyFormatted { codingKey in
            Data(base64Encoded: codingKey.stringValue)
        }

        encoder.outputFormatting = [.prettyPrinted]

        for (_, xmlString) in values {
            let xmlString =
                """
                <container>
                <value>\(xmlString)0</value>
                <value>\(xmlString)0</value>
                </container>
                """
            let xmlData = xmlString.data(using: .utf8)!

            XCTAssertThrowsError(try decoder.decode(Container.self, from: xmlData))
        }
    }

    func testKeyFormatedNoPathError() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        decoder.dataDecodingStrategy = .keyFormatted { codingKey in
            Data(base64Encoded: codingKey.stringValue)
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
        ("testKeyFormated", testKeyFormated),
        ("testKeyFormatedError", testKeyFormatedError),
        ("testKeyFormatedCouldNotDecodeError", testKeyFormatedCouldNotDecodeError),
        ("testKeyFormatedNoPathError", testKeyFormatedNoPathError),
    ]
}
