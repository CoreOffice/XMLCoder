//
//  Created by Max Desiatov on 09/04/2020.
//

import XCTest
import XMLCoder

final class CDATATest: XCTestCase {
    private struct Container: Codable, Equatable {
        let value: Int
        let data: String
    }

    private let xml =
        """
        <container>
           <value>42</value>
           <data><![CDATA[lorem ipsum]]></data>
        </container>
        """.data(using: .utf8)!

    func testXML() throws {
        let decoder = XMLDecoder()
        let result = try decoder.decode(Container.self, from: xml)

        XCTAssertEqual(result, Container(value: 42, data: "lorem ipsum"))
    }

    private struct CData: Codable {
        let string: String
        let int: Int
        let bool: Bool
    }

    private let expectedCData =
        """
        <CData>
            <string><![CDATA[string]]></string>
            <int>123</int>
            <bool>true</bool>
        </CData>
        """

    func testCDataTypes() throws {
        let example = CData(string: "string", int: 123, bool: true)
        let xmlEncoder = XMLEncoder()
        xmlEncoder.stringEncodingStrategy = .cdata
        xmlEncoder.outputFormatting = .prettyPrinted
        let encoded = try xmlEncoder.encode(example)
        XCTAssertEqual(String(data: encoded, encoding: .utf8), expectedCData)
    }
}
