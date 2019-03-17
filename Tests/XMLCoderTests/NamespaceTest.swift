//
//  NamespaceTest.swift
//  XMLCoder
//
//  Created by Max Desiatov on 27/02/2019.
//

import Foundation
import XCTest
@testable import XMLCoder

private let xmlData = """
<h:table xmlns:h="http://www.w3.org/TR/html4/">
  <h:tr>
    <h:td>Apples</h:td>
    <h:td>Bananas</h:td>
  </h:tr>
</h:table>
""".data(using: .utf8)!

private struct Table: Codable, Equatable {
    struct TR: Codable, Equatable {
        let td: [String]
    }

    let tr: TR
}

class NameSpaceTest: XCTestCase {
    func testDecoder() throws {
        let decoder = XMLDecoder()
        decoder.shouldProcessNamespaces = true

        let decoded = try decoder.decode(Table.self, from: xmlData)

        XCTAssertEqual(decoded, Table(tr: .init(td: ["Apples", "Bananas"])))
    }
}
