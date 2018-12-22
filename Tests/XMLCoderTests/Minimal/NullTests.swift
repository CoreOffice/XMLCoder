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

    func testAttribute() {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        encoder.nodeEncodingStrategy = .custom { _, _ in
            return { _ in .attribute }
        }

        do {
            let xmlString =
                """
                <container />
                """
            let xmlData = xmlString.data(using: .utf8)!

            let decoded = try decoder.decode(Container.self, from: xmlData)
            XCTAssertNil(decoded.value)

            let encoded = try encoder.encode(decoded, withRootKey: "container")
            XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
        } catch {
            XCTAssert(false, "failed to decode test xml: \(error)")
        }
    }

    func testElement() {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        encoder.outputFormatting = [.prettyPrinted]

        do {
            let xmlString =
                """
                <container />
                """
            let xmlData = xmlString.data(using: .utf8)!

            let decoded = try decoder.decode(Container.self, from: xmlData)
            XCTAssertNil(decoded.value)

            let encoded = try encoder.encode(decoded, withRootKey: "container")
            XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
        } catch {
            XCTAssert(false, "failed to decode test xml: \(error)")
        }
    }

    static var allTests = [
        ("testAttribute", testAttribute),
        ("testElement", testElement),
    ]
}
