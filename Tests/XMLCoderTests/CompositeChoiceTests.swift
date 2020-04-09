//
//  CompositeChoiceTests.swift
//  XMLCoderTests
//
//  Created by James Bean on 7/15/19.
//

import XCTest
import XMLCoder

private struct IntWrapper: Codable, Equatable {
    let wrapped: Int
}

private struct StringWrapper: Codable, Equatable {
    let wrapped: String
}

private enum IntOrStringWrapper: Equatable {
    case int(IntWrapper)
    case string(StringWrapper)
}

extension IntOrStringWrapper: Codable {
    enum CodingKeys: String, XMLChoiceCodingKey {
        case int
        case string
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self = .int(try container.decode(IntWrapper.self, forKey: .int))
        } catch {
            self = .string(try container.decode(StringWrapper.self, forKey: .string))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .int(value):
            try container.encode(value, forKey: .int)
        case let .string(value):
            try container.encode(value, forKey: .string)
        }
    }
}

final class EnumAssociatedValueTestComposite: XCTestCase {
    var encoder: XMLEncoder {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        return encoder
    }

    private let simpleString = IntOrStringWrapper.string(StringWrapper(wrapped: "A Word About Woke Times"))

    private let xmlSimpleString = """
    <container>
        <string>
            <wrapped>A Word About Woke Times</wrapped>
        </string>
    </container>
    """

    private let simpleArray: [IntOrStringWrapper] = [
        .string(StringWrapper(wrapped: "A Word About Woke Times")),
        .int(IntWrapper(wrapped: 9000)),
        .string(StringWrapper(wrapped: "A Word About Woke Tomes")),
    ]

    private let xmlSimpleArray = """
    <container>
        <string>
            <wrapped>A Word About Woke Times</wrapped>
        </string>
        <int>
            <wrapped>9000</wrapped>
        </int>
        <string>
            <wrapped>A Word About Woke Tomes</wrapped>
        </string>
    </container>
    """

    func testDecodeIntOrStringWrapper() throws {
        let decoded = try XMLDecoder().decode(IntOrStringWrapper.self, from: xmlSimpleString.data(using: .utf8)!)
        XCTAssertEqual(decoded, simpleString)
    }

    func testEncodeIntOrStringWrapper() throws {
        let encoded = try encoder.encode(simpleString, withRootKey: "container")
        XCTAssertEqual(String(data: encoded, encoding: .utf8), xmlSimpleString)
    }

    func testDecodeArrayOfIntOrStringWrappers() throws {
        let decoded = try XMLDecoder().decode([IntOrStringWrapper].self, from: xmlSimpleArray.data(using: .utf8)!)
        XCTAssertEqual(decoded, simpleArray)
    }

    func testEncodeArrayOfIntOrStringWrappers() throws {
        let encoded = try encoder.encode(simpleArray, withRootKey: "container")
        XCTAssertEqual(String(data: encoded, encoding: .utf8), xmlSimpleArray)
    }
}
