//
//  URLTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/19/18.
//

import XCTest
@testable import XMLCoder

class URLTests: XCTestCase {
    typealias Value = URL

    struct Container: Codable, Equatable {
        let value: Value
    }

    let values: [(Value, String)] = [
        (URL(string: "file:///")!, "file:///"),
        (URL(string: "http://example.com")!, "http://example.com"),
    ]

    func testAttribute() {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        encoder.nodeEncodingStrategy = .custom { _, _ in
            return { _ in .attribute }
        }

        for (value, xmlString) in values {
            do {
                let xmlString =
                    """
                    <container value="\(xmlString)" />
                    """
                let xmlData = xmlString.data(using: .utf8)!

                let decoded = try decoder.decode(Container.self, from: xmlData)
                XCTAssertEqual(decoded.value, value)

                let encoded = try encoder.encode(decoded, withRootKey: "container")
                XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
            } catch {
                XCTAssert(false, "failed to decode test xml: \(error)")
            }
        }
    }

    func testElement() {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        encoder.outputFormatting = [.prettyPrinted]

        for (value, xmlString) in values {
            do {
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
            } catch {
                XCTAssert(false, "failed to decode test xml: \(error)")
            }
        }
    }

    static var allTests = [
        ("testAttribute", testAttribute),
        ("testElement", testElement),
    ]
}
