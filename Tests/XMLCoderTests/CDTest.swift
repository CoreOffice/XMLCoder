//
//  CDTest.swift
//  XMLCoderTests
//
//  Created by Shawn Moore on 11/15/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation
import XCTest
@testable import XMLCoder

private struct CDCatalog: Codable, Equatable {
    var cds: [CD]

    enum CodingKeys: String, CodingKey {
        case cds = "CD"
    }
}

private struct CD: Codable, Equatable {
    var title: String
    var artist: String
    var country: String
    var company: String
    var price: Decimal
    var year: Int

    enum CodingKeys: String, CodingKey {
        case title = "TITLE"
        case artist = "ARTIST"
        case country = "COUNTRY"
        case company = "COMPANY"
        case price = "PRICE"
        case year = "YEAR"
    }
}

private let lastCD = CD(title: "Unchain my heart",
                        artist: "Joe Cocker",
                        country: "USA",
                        company: "EMI",
                        price: 8.20,
                        year: 1987)

final class CDTest: XCTestCase {
    func testXML() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        let cdCatalog1 = try decoder.decode(CDCatalog.self,
                                            from: cdCatalogXML)
        XCTAssertEqual(cdCatalog1.cds.count, 26)
        XCTAssertEqual(cdCatalog1.cds[25], lastCD)

        let data = try encoder.encode(cdCatalog1, withRootKey: "CATALOG",
                                      header: XMLHeader(version: 1.0,
                                                        encoding: "UTF-8"))
        let cdCatalog2 = try decoder.decode(CDCatalog.self, from: data)

        XCTAssertEqual(cdCatalog1, cdCatalog2)
    }

    static var allTests = [
        ("testXML", testXML),
    ]
}
