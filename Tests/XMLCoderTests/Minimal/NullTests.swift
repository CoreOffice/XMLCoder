// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Vincent Esche on 12/19/18.
//

import XCTest
@testable import XMLCoder

class NullTests: XCTestCase {
    struct Container: Codable, Equatable {
        let value: Int?
    }

    func testAttribute() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        encoder.nodeEncodingStrategy = .custom { _, _ in
            { _ in .attribute }
        }

        let xmlString =
            """
            <container />
            """
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(Container.self, from: xmlData)
        XCTAssertNil(decoded.value)

        let encoded = try encoder.encode(decoded, withRootKey: "container")
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
    }

    func testElement() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        encoder.outputFormatting = [.prettyPrinted]

        let xmlString =
            """
            <container />
            """
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(Container.self, from: xmlData)
        XCTAssertNil(decoded.value)

        let encoded = try encoder.encode(decoded, withRootKey: "container")
        XCTAssertEqual(String(data: encoded, encoding: .utf8)!, xmlString)
    }

    func testNullElement() {
        let decoder = XMLDecoder()

        let xmlString =
            """
            <container>
                <value/>
            </container>
            """
        let xmlData = xmlString.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Container.self, from: xmlData))
    }
}
