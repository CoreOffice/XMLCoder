// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Benjamin Wetherfield on 9/28/19.
//

import Foundation
import XCTest
@testable import XMLCoder

private struct Policy: Encodable {
    @XMLAttributeNode var name: String
    var initial: String

    enum CodingKeys: String, CodingKey {
        case name, initial
    }
}

let expected = """
<?xml version="1.0" encoding="UTF-8"?>
<policy name="generic">
    <initial>more xml here</initial>
</policy>
"""

final class RootLevelAttributeTest: XCTestCase {
    func testPolicyEncodingAtRoot() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let policy = Policy(name: .init("generic"), initial: "more xml here")
        let data = try encoder.encode(policy,
                                      withRootKey: "policy",
                                      header: XMLHeader(version: 1.0, encoding: "UTF-8"))
        XCTAssertEqual(String(data: data, encoding: .utf8)!, expected)
    }
}
