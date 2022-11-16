// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Max Desiatov on 02/05/2019.
//

import XCTest
@testable import XMLCoder

private let systemXML = """
<!DOCTYPE si SYSTEM "http://example.com/myService_v1.dtd">
<si><t>blah</t></si>
""".data(using: .utf8)!

private let publicXML = """
<!DOCTYPE si PUBLIC "-//Domain//DTD MyService v1//EN" "http://example.com/myService_v1.dtd">
<si><t>blah</t></si>
""".data(using: .utf8)!

private struct CapitalizedItem: Codable, Equatable {
    public let text: String
    
    enum CodingKeys: String, CodingKey {
        case text = "t"
    }
}

final class DocTypeTests: XCTestCase {
    func testPublicDocType() throws {
        let decoder = XMLDecoder()
        let decodedResult = try decoder.decode(CapitalizedItem.self, from: publicXML)
        XCTAssertEqual(decodedResult.text, "blah")
        
        let encoder = XMLEncoder()
        let encoded = try encoder.encode(
            decodedResult,
            withRootKey: "si",
            doctype: .public(
                rootElement: "si",
                dtdName: "-//Domain//DTD MyService v1//EN",
                dtdLocation: "http://example.com/myService_v1.dtd"
            )
        )
        
        XCTAssertEqual(encoded, publicXML)
        
        let decodedResult2 = try decoder.decode(CapitalizedItem.self, from: encoded)
        XCTAssertEqual(decodedResult, decodedResult2)
    }
    
    func testSystemDocType() throws {
        let decoder = XMLDecoder()
        let decodedResult = try decoder.decode(CapitalizedItem.self, from: systemXML)
        XCTAssertEqual(decodedResult.text, "blah")
        
        let encoder = XMLEncoder()
        let encoded = try encoder.encode(
            decodedResult,
            withRootKey: "si",
            doctype: .system(
                rootElement: "si",
                dtdLocation: "http://example.com/myService_v1.dtd"
            )
        )
        
        XCTAssertEqual(encoded, systemXML)
        
        let decodedResult2 = try decoder.decode(CapitalizedItem.self, from: encoded)
        XCTAssertEqual(decodedResult, decodedResult2)
    }
}
