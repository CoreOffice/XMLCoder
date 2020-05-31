// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Max Desiatov on 24/01/2019.
//

import XCTest
@testable import XMLCoder

private struct ExpectNonNil: Decodable, Equatable {
    var optional: String? = ""

    private enum CodingKeys: String, CodingKey {
        case optional
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.optional) {
            optional = try container.decode(String.self, forKey: .optional)
        }
    }
}

private struct ExpectOptional: Decodable, Equatable {
    var optional: String? = ""

    private enum CodingKeys: String, CodingKey {
        case optional
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.optional) {
            optional = try container.decode(String?.self, forKey: .optional)
        }
    }
}

private struct DecodeIfPresent: Decodable, Equatable {
    var optional: String? = ""

    private enum CodingKeys: String, CodingKey {
        case optional
    }

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        optional = try container.decodeIfPresent(String.self, forKey: .optional)
    }
}

class OptionalTests: XCTestCase {
    func testMissing() throws {
        let decoder = XMLDecoder()

        let xml = """
        <container><optional></optional></container>
        """.data(using: .utf8)!

        let decoded1 = try decoder.decode(ExpectOptional.self, from: xml)
        XCTAssertEqual(decoded1, ExpectOptional())
        let decoded2 = try decoder.decode(DecodeIfPresent.self, from: xml)
        XCTAssertEqual(decoded2, DecodeIfPresent())
    }
}
