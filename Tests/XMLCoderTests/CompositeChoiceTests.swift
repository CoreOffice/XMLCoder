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

extension IntOrStringWrapper: XMLChoiceCodable {

    enum CodingKeys: String, CodingKey {
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
        var container  = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .int(value):
            try container.encode(value, forKey: .int)
        case let .string(value):
            try container.encode(value, forKey: .string)
        }
    }
}

class CompositeChoiceTests: XCTestCase {

    func testIntOrStringWrapper() throws {
        let xml = """
        <container>
            <string>
                <wrapped>A Word About Woke Times</wrapped>
            </string>
        </container>
        """
        let result = try XMLDecoder().decode(IntOrStringWrapper.self, from: xml.data(using: .utf8)!)
        let expected = IntOrStringWrapper.string(StringWrapper(wrapped: "A Word About Woke Times"))
        XCTAssertEqual(result, expected)
    }

    func testArrayOfIntOrStringWrappers() throws {
        let xml = """
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
        let result = try XMLDecoder().decode([IntOrStringWrapper].self, from: xml.data(using: .utf8)!)
        let expected: [IntOrStringWrapper] = [
            .string(StringWrapper(wrapped: "A Word About Woke Times")),
            .int(IntWrapper(wrapped: 9000)),
            .string(StringWrapper(wrapped: "A Word About Woke Tomes")),
        ]
        XCTAssertEqual(result, expected)
    }
}
