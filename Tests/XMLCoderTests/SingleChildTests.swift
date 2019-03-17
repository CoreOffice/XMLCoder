//
//  SingleChild.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 18/01/2019.
//

import XCTest
@testable import XMLCoder

struct ProudParent: Codable, Equatable {
    var myChildAge: [Int]
}

final class Test: XCTestCase {
    func testEncoder() throws {
        let encoder = XMLEncoder()

        let parent = ProudParent(myChildAge: [2])
        let expectedXML =
            """
            <ProudParent><myChildAge>2</myChildAge></ProudParent>
            """.data(using: .utf8)!

        let encodedXML = try encoder.encode(parent, withRootKey: "ProudParent")

        XCTAssertEqual(expectedXML, encodedXML)
    }

    func testDecoder() throws {
        let decoder = XMLDecoder()

        let parent = ProudParent(myChildAge: [2])
        let xml =
            """
            <ProudParent><myChildAge>2</myChildAge></ProudParent>
            """.data(using: .utf8)!

        let decoded = try decoder.decode(ProudParent.self, from: xml)

        XCTAssertEqual(decoded, parent)
    }

    static var allTests = [
        ("testDecoder", testDecoder),
    ]
}
