// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Max Desiatov on 05/10/2019.
//

import Foundation
import XCTest
@testable import XMLCoder

private let xml =
    """
    <root>
    <aResponse>&lt;uesb2b:response
    xmlns:uesb2b=&quot;http://services.b2b.ues.ut.uhg.com/types/plans/&quot;
    xmlns=&quot;http://services.b2b.ues.ut.uhg.com/types/plans/&quot;&gt;&#xd;
    &lt;uesb2b:st cd=&quot;GA&quot; /&gt;&#xd;
    &lt;uesb2b:obligId val=&quot;01&quot; /&gt;&#xd;
    &lt;uesb2b:shrArrangementId val=&quot;00&quot; /&gt;&#xd;
    &lt;uesb2b:busInsType val=&quot;CG&quot; /&gt;&#xd;
    &lt;uesb2b:metalPlans typ=&quot;Array&quot;
    </aResponse>
    </root>
    """.data(using: .utf8)!

private let expectedResponse =
    """
    <uesb2b:response
    xmlns:uesb2b="http://services.b2b.ues.ut.uhg.com/types/plans/"
    xmlns="http://services.b2b.ues.ut.uhg.com/types/plans/">\r
    <uesb2b:st cd="GA" />\r
    <uesb2b:obligId val="01" />\r
    <uesb2b:shrArrangementId val="00" />\r
    <uesb2b:busInsType val="CG" />\r
    <uesb2b:metalPlans typ="Array"

    """

private struct Response: Codable {
    let aResponse: String
}

private let attributeNewline = Attribute(
    id: .init("""
    Got an attributed String.
    Will create a image.


    """)
)

private let attributeNewlineEncoded =
    "<Attribute id=\"Got an attributed String.&#10;Will create a image.&#10;&#10;\" />"

private struct Attribute: Codable, DynamicNodeEncoding, Equatable {
    @XMLAttributeNode var id: String

    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        return .attribute
    }
}

final class EscapedCharactersTest: XCTestCase {
    func testDefaultDecoding() throws {
        let decoder = XMLDecoder()
        decoder.trimValueWhitespaces = false
        let response = try decoder.decode(Response.self, from: xml).aResponse
        XCTAssertEqual(response, expectedResponse)
    }

    func testDefaultEncoding() throws {
        let encoder = XMLEncoder()
        let result = try String(
            data: encoder.encode(Response(aResponse: " \"\"\" ")),
            encoding: .utf8
        )!
        XCTAssertEqual(result, "<Response><aResponse> &quot;&quot;&quot; </aResponse></Response>")
    }

    func testQuoteEncoding() throws {
        let encoder = XMLEncoder()
        encoder.charactersEscapedInElements = []
        let result = try String(
            data: encoder.encode(Response(aResponse: " \"\"\" ")),
            encoding: .utf8
        )!
        XCTAssertEqual(result, "<Response><aResponse> \"\"\" </aResponse></Response>")
    }

    func testNewlineAttributeEncoding() throws {
        let decoder = XMLDecoder()
        decoder.trimValueWhitespaces = false
        XCTAssertEqual(
            try decoder.decode(Attribute.self, from: attributeNewlineEncoded.data(using: .utf8)!),
            attributeNewline
        )

        let encoder = XMLEncoder()
        encoder.charactersEscapedInAttributes += [("\n", "&#10;")]
        let result = try String(data: encoder.encode(attributeNewline), encoding: .utf8)!
        XCTAssertEqual(result, attributeNewlineEncoded)
    }
}
