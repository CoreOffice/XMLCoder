//
//  Created by Max Desiatov on 09/04/2020.
//

import XCTest
import XMLCoder

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

final class CDATATest: XCTestCase {
    func testXML() throws {
        let decoder = XMLDecoder()
        let result = try decoder.decode(Container.self, from: xml)

        XCTAssertEqual(result, Container(value: 42, data: "lorem ipsum"))
    }
}
