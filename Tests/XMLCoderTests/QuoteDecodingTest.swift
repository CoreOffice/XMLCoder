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

private struct Response: Decodable {
    let aResponse: String
}

final class QuoteDecodingTest: XCTestCase {
    func testQuoteDecoding() throws {
        let decoder = XMLDecoder()
        decoder.trimValueWhitespaces = false
        let response = try decoder.decode(Response.self, from: xml).aResponse
        XCTAssertEqual(response, expectedResponse)
    }
}
