//
//  SpacePreserveTest.swift
//  XMLCoder
//
//  Created by Max Desiatov on 29/04/2019.
//

import XCTest
@testable import XMLCoder

private let xml = """
<t xml:space="preserve"> </t>
""".data(using: .utf8)!

final class SpacePreserveTest: XCTestCase {
    func testDecoder() throws {
        let result = try XMLDecoder().decode(String?.self, from: xml)
        XCTAssertNil(result)
    }

    static var allTests = [
        ("testDecoder", testDecoder),
    ]
}
