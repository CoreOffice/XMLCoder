//
//  KeyedIntTests.swift
//  XMLCoder
//
//  Created by Matvii Hodovaniuk on 1/8/19.
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

private struct ContainerInt: Codable, Equatable, IntegerContainer {
    let value: Int
}

private struct ContainerInt8: Codable, Equatable, IntegerContainer {
    let value: Int8
}

private struct ContainerInt16: Codable, Equatable, IntegerContainer {
    let value: Int16
}

private struct ContainerInt32: Codable, Equatable, IntegerContainer {
    let value: Int32
}

private struct ContainerInt64: Codable, Equatable, IntegerContainer {
    let value: Int64
}

private struct ContainerUInt: Codable, Equatable, IntegerContainer {
    let value: UInt
}

private struct ContainerUInt8: Codable, Equatable, IntegerContainer {
    let value: UInt8
}

private struct ContainerUInt16: Codable, Equatable, IntegerContainer {
    let value: UInt16
}

private struct ContainerUInt32: Codable, Equatable, IntegerContainer {
    let value: UInt32
}

private struct ContainerUInt64: Codable, Equatable, IntegerContainer {
    let value: UInt64
}

class KeyedIntTests: XCTestCase {
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
            { _ in .attribute }
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
        try testMissing(ContainerInt.self)
        try testMissing(ContainerInt8.self)
        try testMissing(ContainerInt16.self)
        try testMissing(ContainerInt32.self)
        try testMissing(ContainerInt64.self)
        try testMissing(ContainerUInt.self)
        try testMissing(ContainerUInt8.self)
        try testMissing(ContainerUInt16.self)
        try testMissing(ContainerUInt32.self)
        try testMissing(ContainerUInt64.self)
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
        try testAttribute(ContainerInt.self)
        try testAttribute(ContainerInt8.self)
        try testAttribute(ContainerInt16.self)
        try testAttribute(ContainerInt32.self)
        try testAttribute(ContainerInt64.self)
        try testAttribute(ContainerUInt.self)
        try testAttribute(ContainerUInt8.self)
        try testAttribute(ContainerUInt16.self)
        try testAttribute(ContainerUInt32.self)
        try testAttribute(ContainerUInt64.self)
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
        try testElement(ContainerInt.self)
        try testElement(ContainerInt8.self)
        try testElement(ContainerInt16.self)
        try testElement(ContainerInt32.self)
        try testElement(ContainerInt64.self)
        try testElement(ContainerUInt.self)
        try testElement(ContainerUInt8.self)
        try testElement(ContainerUInt16.self)
        try testElement(ContainerUInt32.self)
        try testElement(ContainerUInt64.self)
    }

    static var allTests = [
        ("testIntegerTypeMissing", testIntegerTypeMissing),
        ("testIntegerTypeAttribute", testIntegerTypeAttribute),
        ("testIntegerTypeElement", testIntegerTypeElement),
    ]
}
