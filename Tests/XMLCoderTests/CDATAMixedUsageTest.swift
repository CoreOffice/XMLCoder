//
//  CDATAMixedUsageTest.swift
//  XMLCoderTests
//
//  Created by Johan Kool on 15/03/2023.
//

import XCTest
import XMLCoder

final class CDATAMixedUsageTest: XCTestCase {
    private struct DataEntry: Codable, Equatable {
        let value: String
        enum CodingKeys: String, CodingKey {
            case value = ""
        }
    }
    
    private struct Container: Codable, Equatable {
        let data: [DataEntry]
    }
    
    private let xml =
        """
        <container>
           <data><![CDATA[lorem ipsum]]></data>
           <data>bla bla</data>
        </container>
        """.data(using: .utf8)!
    
    func testXMLWithMixedCDATAUsage() throws {
        let decoder = XMLDecoder()
        let result = try decoder.decode(Container.self, from: xml)
        XCTAssertEqual(result, Container(data: [.init(value: "lorem ipsum"), .init(value: "bla bla")]))
    }
}
