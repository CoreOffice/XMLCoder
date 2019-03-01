//
//  UnkeyedIntTests.swift
//  XMLCoder
//
//  Created by Matvii Hodovaniuk on 1/8/19.
//

import XCTest
@testable import XMLCoder

protocol IntegerArrayContainer {
    associatedtype Integer: BinaryInteger
    var value: [Integer] { get }
}

extension IntegerArrayContainer {
    var intValue: [Int] {
        return value.map { Int($0) }
    }
}

enum CodingKeys: CodingKey {
    case value
}

private func decodeArray<T>(
    _ decoder: Decoder,
    decode: (inout UnkeyedDecodingContainer) throws -> T
) throws -> [T] {
    let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
    var container = try keyedContainer.nestedUnkeyedContainer(forKey: .value)

    var decoded = [T]()
    var finished = false

    while !finished {
        do {
            decoded.append(try decode(&container))
        } catch DecodingError.valueNotFound {
            finished = true
        } catch {
            throw error
        }
    }

    return decoded
}

struct UnkeyedContainerInt<T>: Codable, Equatable, IntegerArrayContainer where T: Codable & Equatable & BinaryInteger {
    let value: [T]

    init(from decoder: Decoder) throws {
        value = try decodeArray(decoder) {
            try $0.decode(T.self)
        }
    }
}

struct UnkeyedContainerInt8: Codable, Equatable, IntegerArrayContainer {
    let value: [Int8]

    init(from decoder: Decoder) throws {
        value = try decodeArray(decoder) {
            try $0.decode(Int8.self)
        }
    }
}

struct UnkeyedContainerInt16: Codable, Equatable, IntegerArrayContainer {
    let value: [Int16]

    init(from decoder: Decoder) throws {
        value = try decodeArray(decoder) {
            try $0.decode(Int16.self)
        }
    }
}

struct UnkeyedContainerInt32: Codable, Equatable, IntegerArrayContainer {
    let value: [Int32]

    init(from decoder: Decoder) throws {
        value = try decodeArray(decoder) {
            try $0.decode(Int32.self)
        }
    }
}

struct UnkeyedContainerInt64: Codable, Equatable, IntegerArrayContainer {
    let value: [Int64]

    init(from decoder: Decoder) throws {
        value = try decodeArray(decoder) {
            try $0.decode(Int64.self)
        }
    }
}

struct UnkeyedContainerUInt8: Codable, Equatable, IntegerArrayContainer {
    let value: [UInt8]

    init(from decoder: Decoder) throws {
        value = try decodeArray(decoder) {
            try $0.decode(UInt8.self)
        }
    }
}

struct UnkeyedContainerUInt16: Codable, Equatable, IntegerArrayContainer {
    let value: [UInt16]

    init(from decoder: Decoder) throws {
        value = try decodeArray(decoder) {
            try $0.decode(UInt16.self)
        }
    }
}

struct UnkeyedContainerUInt32: Codable, Equatable, IntegerArrayContainer {
    let value: [UInt32]

    init(from decoder: Decoder) throws {
        value = try decodeArray(decoder) {
            try $0.decode(UInt32.self)
        }
    }
}

struct UnkeyedContainerUInt64: Codable, Equatable, IntegerArrayContainer {
    let value: [UInt64]

    init(from decoder: Decoder) throws {
        value = try decodeArray(decoder) {
            try $0.decode(UInt64.self)
        }
    }
}

class UnkeyedIntTests: XCTestCase {
    func testInt<T: Codable & IntegerArrayContainer>(_ type: T.Type) throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]

        let xmlString =
            """
            <container>
                <value>42</value>
                <value>43</value>
                <value>44</value>
            </container>
            """

        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(type, from: xmlData)
        XCTAssertEqual(decoded.intValue, [42, 43, 44])

        let encoded = try encoder.encode(decoded, withRootKey: "container")
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
    }

    func testInts() throws {
        try testInt(UnkeyedContainerInt<Int8>.self)
        try testInt(UnkeyedContainerInt<Int16>.self)
        try testInt(UnkeyedContainerInt<Int32>.self)
        try testInt(UnkeyedContainerInt<Int64>.self)
        try testInt(UnkeyedContainerInt<UInt8>.self)
        try testInt(UnkeyedContainerInt<UInt16>.self)
        try testInt(UnkeyedContainerInt<UInt32>.self)
        try testInt(UnkeyedContainerInt<UInt64>.self)
        try testInt(UnkeyedContainerInt8.self)
        try testInt(UnkeyedContainerInt16.self)
        try testInt(UnkeyedContainerInt32.self)
        try testInt(UnkeyedContainerInt64.self)
        try testInt(UnkeyedContainerUInt8.self)
        try testInt(UnkeyedContainerUInt16.self)
        try testInt(UnkeyedContainerUInt32.self)
        try testInt(UnkeyedContainerUInt64.self)
    }

    static var allTests = [
        ("testInts", testInts),
    ]
}
