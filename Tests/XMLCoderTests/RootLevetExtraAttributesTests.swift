// Copyright (c) 2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import XCTest
@testable import XMLCoder

final class RootLevetExtraAttributesTests: XCTestCase {
    private let encoder = XMLEncoder()

    func testExtraAttributes() {
        let policy = Policy(name: "test", initial: "extra root attributes")

        let extraRootAttributes = [
            "xmlns": "http://www.nrf-arts.org/IXRetail/namespace",
            "xmlns:xsd": "http://www.w3.org/2001/XMLSchema",
            "xmlns:xsi": "http://www.w3.org/2001/XMLSchema-instance",
        ]

        encoder.keyEncodingStrategy = .lowercased
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let data = try encoder.encode(policy,
                                          rootAttributes: extraRootAttributes)

            let dataString = String(data: data, encoding: .utf8)
            XCTAssertNotNil(dataString, "failed to encode object")

            let expected = """
            <policy name="test" \
            xmlns="http://www.nrf-arts.org/IXRetail/namespace" \
            xmlns:xsd="http://www.w3.org/2001/XMLSchema" \
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                <initial>extra root attributes</initial>
            </policy>
            """

            XCTAssertEqual(dataString!, expected, "")
        } catch {
            XCTAssertThrowsError(error)
        }
    }
}

private struct Policy: Encodable, DynamicNodeEncoding {
    var name: String
    var initial: String

    enum CodingKeys: String, CodingKey {
        case name, initial
    }

    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case Policy.CodingKeys.name: return .attribute
        default: return .element
        }
    }
}
