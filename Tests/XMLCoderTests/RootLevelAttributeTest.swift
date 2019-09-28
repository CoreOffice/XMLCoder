//
//  RootLevelAttributeTest.swift
//  XMLCoderTests
//
//  Created by Benjamin Wetherfield on 9/28/19.
//

import Foundation
import XCTest
@testable import XMLCoder

private struct Policy: Encodable, DynamicNodeEncoding {
    var name: String
    var initial: String

    enum CodingKeys: String, CodingKey {
        case name, initial
    }

    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case Policy.CodingKeys.name: return .attribute
        default: return .element
        }
    }
}

let expected = """
<?xml version="1.0" encoding="UTF-8"?>
<policy name="generic">
    <initial>more xml here</initial>
</policy>
"""

class RootLevelAttributeTest: XCTestCase {
    func testPolicyEncodingAtRoot() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let policy = Policy(name: "generic", initial: "more xml here")
        let data = try encoder.encode(policy,
                                       withRootKey: "policy",
                                       header: XMLHeader(version: 1.0, encoding: "UTF-8"))
        XCTAssertEqual(String(data: data, encoding: .utf8)!, expected)
    }
}
