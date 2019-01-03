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
        (0, "0"),
        (42, "42"),
    ]

    func testMissing<T: Decodable>(_ type: T.Type) throws {
        let decoder = XMLDecoder()
        let xmlString = "<container />"
        let xmlData = xmlString.data(using: .utf8)!
        XCTAssertThrowsError(try decoder.decode(type, from: xmlData))
    }

    func testAttribute<T: Codable & IntegerContainer>(_ type: T.Type) throws {
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

            let encoded = try encoder.encode(decoded, withRootKey: "container")
            XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
        }
    }

    func testElement<T: Codable & IntegerContainer>(_ type: T.Type) throws {
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
            XCTAssertEqual(decoded.intValue, value)

            let encoded = try encoder.encode(decoded, withRootKey: "container")
            XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
        }
    }

    func testIntegerTypeMissing() throws {
        try testMissing(Container<Int>.self)
        try testMissing(Container<Int8>.self)
        try testMissing(Container<Int16>.self)
        try testMissing(Container<Int32>.self)
        try testMissing(Container<Int64>.self)
        try testMissing(Container<UInt>.self)
        try testMissing(Container<UInt8>.self)
        try testMissing(Container<UInt16>.self)
        try testMissing(Container<UInt32>.self)
        try testMissing(Container<UInt64>.self)
    }

    func testIntegerTypeAttribute() throws {
        try testAttribute(Container<Int>.self)
        try testAttribute(Container<Int8>.self)
        try testAttribute(Container<Int16>.self)
        try testAttribute(Container<Int32>.self)
        try testAttribute(Container<Int64>.self)
        try testAttribute(Container<UInt>.self)
        try testAttribute(Container<UInt8>.self)
        try testAttribute(Container<UInt16>.self)
        try testAttribute(Container<UInt32>.self)
        try testAttribute(Container<UInt64>.self)
    }

    func testIntegerTypeElement() throws {
        try testElement(Container<Int>.self)
        try testElement(Container<Int8>.self)
        try testElement(Container<Int16>.self)
        try testElement(Container<Int32>.self)
        try testElement(Container<Int64>.self)
        try testElement(Container<UInt>.self)
        try testElement(Container<UInt8>.self)
        try testElement(Container<UInt16>.self)
        try testElement(Container<UInt32>.self)
        try testElement(Container<UInt64>.self)
    }

    static var allTests = [
        ("testIntegerTypeMissing", testIntegerTypeMissing),
        ("testIntegerTypeAttribute", testIntegerTypeAttribute),
        ("testIntegerTypeElement", testIntegerTypeElement),
    ]
}
