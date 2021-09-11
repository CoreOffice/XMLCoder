// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by John Woo on 7/29/21.
//

import Foundation

import XCTest
@testable import XMLCoder

class NestedStringList: XCTestCase {

    struct TypeWithNestedStringList: Decodable {
        let nestedStringList: [[String]]

        enum CodingKeys: String, CodingKey {
            case nestedStringList
        }

        enum NestedMemberKeys: String, CodingKey {
            case member
        }

        public init (from decoder: Decoder) throws {
            let containerValues = try decoder.container(keyedBy: CodingKeys.self)
            let nestedStringListWrappedContainer = try containerValues.nestedContainer(keyedBy: NestedMemberKeys.self, forKey: .nestedStringList)
            let nestedStringListContainer = try nestedStringListWrappedContainer.decodeIfPresent([[String]].self, forKey: .member)
            var nestedStringListBuffer: [[String]] = []
            if let nestedStringListContainer = nestedStringListContainer {
                nestedStringListBuffer = [[String]]()
                var listBuffer0: [String]?
                for listContainer0 in nestedStringListContainer {
                    listBuffer0 = [String]()
                    for stringContainer1 in listContainer0 {
                            listBuffer0?.append(stringContainer1)
                    }
                    if let listBuffer0 = listBuffer0 {
                        nestedStringListBuffer.append(listBuffer0)
                    }
                }
            }
            nestedStringList = nestedStringListBuffer
        }
    }

    func testRemoveWhitespaceElements() throws {
        let decoder = XMLDecoder(trimValueWhitespaces: false, removeWhitespaceElements: true)
        let xmlString =
            """
            <TypeWithNestedStringList>
                <nestedStringList>
                    <member>
                        <member>foo: &amp;lt;&#xD;&#10;</member>
                        <member>bar: &amp;lt;&#xD;&#10;</member>
                    </member>
                    <member>
                        <member>baz: &amp;lt;&#xD;&#10;</member>
                        <member>qux: &amp;lt;&#xD;&#10;</member>
                    </member>
                </nestedStringList>
            </TypeWithNestedStringList>
            """
        let xmlData = xmlString.data(using: .utf8)!

        let decoded = try decoder.decode(TypeWithNestedStringList.self, from: xmlData)
        XCTAssertEqual(decoded.nestedStringList[0][0], "foo: &lt;\r\n")
        XCTAssertEqual(decoded.nestedStringList[0][1], "bar: &lt;\r\n")
        XCTAssertEqual(decoded.nestedStringList[1][0], "baz: &lt;\r\n")
        XCTAssertEqual(decoded.nestedStringList[1][1], "qux: &lt;\r\n")
    }
}
