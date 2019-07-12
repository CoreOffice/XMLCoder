//
//  EnumAssociatedValueTestComposite.swift
//  XMLCoderTests
//
//  Created by James Bean on 7/12/19.
//

import XCTest
import XMLCoder

private struct IntWrapper: Decodable, Equatable {
    let wrapped: Int
}

private struct StringWrapper: Decodable, Equatable {
    let wrapped: String
}

private enum IntOrStringWrapper: Equatable {
    case int(IntWrapper)
    case string(StringWrapper)
}

extension IntOrStringWrapper: Decodable {

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
}


class EnumAssociatedValueTestComposite: XCTestCase {

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
