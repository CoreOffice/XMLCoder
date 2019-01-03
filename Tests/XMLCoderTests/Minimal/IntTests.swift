//
//  IntTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/19/18.
//

import XCTest
@testable import XMLCoder

protocol IntegerContainer {
    associatedtype Integer: BinaryInteger

    var value: Integer { get }
}

extension IntegerContainer {
    var intValue: Int {
        return Int(value)
    }
}

class IntTests: XCTestCase {
    typealias Value = Int

    struct Container<T>: Codable, Equatable, IntegerContainer where T: Codable & Equatable & BinaryInteger {
        let value: T
    }

    let values: [(Value, String)] = [
        (-42, "-42"),
        (0, "0"),
        (42, "42"),
    ]

    func testMissing<T: Decodable>(_ type: T.Type) throws {
        let decoder = XMLDecoder()
        let xmlString = "<container />"
        let xmlData = xmlString.data(using: .utf8)!
        XCTAssertThrowsError(try decoder.decode(type, from: xmlData))
    }

    func testAttribute<T: Decodable & IntegerContainer>(_ type: T.Type) throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        encoder.nodeEncodingStrategy = .custom { _, _ in
            return { _ in .attribute }
        }

        for (value, xmlString) in values {
            let xmlString =
                """
                <container value="\(xmlString)" />
                """
            let xmlData = xmlString.data(using: .utf8)!

            let decoded = try decoder.decode(type, from: xmlData)
            XCTAssertEqual(decoded.intValue, value)

            let encoded = try encoder.encode(decoded as type, withRootKey: "container")
            XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
        }
    }

    func testElement<T: Decodable>(_ type: T.Type) throws {
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

            let decoded = try decoder.decode(type, from: xmlData)
            XCTAssertEqual(decoded.value, value)

            let encoded = try encoder.encode(decoded, withRootKey: "container")
            XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
        }
    }

    func differentTypeTestMissing() throws {
        try testMissing(Container<Int>.self)
        try testMissing(Container<Int8>.self)
        try testMissing(Container<Int16>.self)
    }

    func differentTypeTestAttribute() throws {
        try testAttribute(Container<Int>.self)
        try testAttribute(Container<Int8>.self)
        try testAttribute(Container<Int16>.self)
    }

    func differentTypeTestElement() throws {
        try testElement(Container<Int>.self)
        try testElement(Container<Int8>.self)
        try testElement(Container<Int16>.self)
    }

    static var allTests = [
        ("differentTypeTestMissing", differentTypeTestMissing),
        ("differentTypeTestAttribute", differentTypeTestAttribute),
        ("differentTypeTestElement", differentTypeTestElement),
    ]
}
