//
//  Books.swift
//  XMLCoderTests
//
//  Created by Shawn Moore on 11/15/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation
import XCTest
@testable import XMLCoder

private let bookXML = """
<?xml version="1.0" encoding="UTF-8"?>
<book id="bk101">
    <author>Gambardella, Matthew</author>
    <title>XML Developer&apos;s Guide</title>
    <genre>Computer</genre>
    <price>44.95</price>
    <description>An in-depth look at creating applications
        with XML.</description>
    <publish_date>2000-10-01</publish_date>
</book>
""".data(using: .utf8)!

private let catalogXML = """
<?xml version="1.0"?>
<catalog>
    <book id="bk101">
        <author>Gambardella, Matthew</author>
        <title>XML Developer's Guide</title>
        <genre>Computer</genre>
        <price>44.95</price>
        <publish_date>2000-10-01</publish_date>
        <description>An in-depth look at creating applications
            with XML.</description>
    </book>
    <book id="bk102">
        <author>Ralls, Kim</author>
        <title>Midnight Rain</title>
        <genre>Fantasy</genre>
        <price>5.95</price>
        <publish_date>2000-12-16</publish_date>
        <description>A former architect battles corporate zombies,
            an evil sorceress, and her own childhood to become queen
            of the world.</description>
    </book>
    <book id="bk103">
        <author>Corets, Eva</author>
        <title>Maeve Ascendant</title>
        <genre>Fantasy</genre>
        <price>5.95</price>
        <publish_date>2000-11-17</publish_date>
        <description>After the collapse of a nanotechnology
            society in England, the young survivors lay the
            foundation for a new society.</description>
    </book>
    <book id="bk104">
        <author>Corets, Eva</author>
        <title>Oberon's Legacy</title>
        <genre>Fantasy</genre>
        <price>5.95</price>
        <publish_date>2001-03-10</publish_date>
        <description>In post-apocalypse England, the mysterious
            agent known only as Oberon helps to create a new life
            for the inhabitants of London. Sequel to Maeve
            Ascendant.</description>
    </book>
    <book id="bk105">
        <author>Corets, Eva</author>
        <title>The Sundered Grail</title>
        <genre>Fantasy</genre>
        <price>5.95</price>
        <publish_date>2001-09-10</publish_date>
        <description>The two daughters of Maeve, half-sisters,
            battle one another for control of England. Sequel to
            Oberon's Legacy.</description>
    </book>
    <book id="bk106">
        <author>Randall, Cynthia</author>
        <title>Lover Birds</title>
        <genre>Romance</genre>
        <price>4.95</price>
        <publish_date>2000-09-02</publish_date>
        <description>When Carla meets Paul at an ornithology
            conference, tempers fly as feathers get ruffled.</description>
    </book>
    <book id="bk107">
        <author>Thurman, Paula</author>
        <title>Splish Splash</title>
        <genre>Romance</genre>
        <price>4.95</price>
        <publish_date>2000-11-02</publish_date>
        <description>A deep sea diver finds true love twenty
            thousand leagues beneath the sea.</description>
    </book>
    <book id="bk108">
        <author>Knorr, Stefan</author>
        <title>Creepy Crawlies</title>
        <genre>Horror</genre>
        <price>4.95</price>
        <publish_date>2000-12-06</publish_date>
        <description>An anthology of horror stories about roaches,
            centipedes, scorpions  and other insects.</description>
    </book>
    <book id="bk109">
        <author>Kress, Peter</author>
        <title>Paradox Lost</title>
        <genre>Science Fiction</genre>
        <price>6.95</price>
        <publish_date>2000-11-02</publish_date>
        <description>After an inadvertant trip through a Heisenberg
            Uncertainty Device, James Salway discovers the problems
            of being quantum.</description>
    </book>
    <book id="bk110">
        <author>O'Brien, Tim</author>
        <title>Microsoft .NET: The Programming Bible</title>
        <genre>Computer</genre>
        <price>36.95</price>
        <publish_date>2000-12-09</publish_date>
        <description>Microsoft's .NET initiative is explored in
            detail in this deep programmer's reference.</description>
    </book>
    <book id="bk111">
        <author>O'Brien, Tim</author>
        <title>MSXML3: A Comprehensive Guide</title>
        <genre>Computer</genre>
        <price>36.95</price>
        <publish_date>2000-12-01</publish_date>
        <description>The Microsoft MSXML3 parser is covered in
            detail, with attention to XML DOM interfaces, XSLT processing,
            SAX and more.</description>
    </book>
    <book id="bk112">
        <author>Galos, Mike</author>
        <title>Visual Studio 7: A Comprehensive Guide</title>
        <genre>Computer</genre>
        <price>49.95</price>
        <publish_date>2001-04-16</publish_date>
        <description>Microsoft Visual Studio 7 is explored in depth,
            looking at how Visual Basic, Visual C++, C#, and ASP+ are
            integrated into a comprehensive development
            environment.</description>
    </book>
</catalog>

""".data(using: .utf8)!

private struct Catalog: Codable, Equatable {
    var books: [Book]

    enum CodingKeys: String, CodingKey {
        case books = "book"
    }
}

private struct Book: Codable, Equatable, DynamicNodeEncoding {
    var id: String
    var author: String
    var title: String
    var genre: Genre
    var price: Double
    var publishDate: Date
    var description: String

    enum CodingKeys: String, CodingKey {
        case id, author, title, genre, price, description

        case publishDate = "publish_date"
    }

    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case CodingKeys.id:
            return .attribute
        default:
            return .element
        }
    }
}

private enum Genre: String, Codable {
    case computer = "Computer"
    case fantasy = "Fantasy"
    case romance = "Romance"
    case horror = "Horror"
    case sciFi = "Science Fiction"
}

final class BooksTest: XCTestCase {
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    func testBookXML() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        encoder.outputFormatting = [.prettyPrinted]

        decoder.dateDecodingStrategy = .formatted(formatter)
        encoder.dateEncodingStrategy = .formatted(formatter)

        let book1 = try decoder.decode(Book.self, from: bookXML)
        XCTAssertEqual(book1.publishDate,
                       Date(timeIntervalSince1970: 970_358_400))

        XCTAssertEqual(book1.title, "XML Developer's Guide")

        let data = try encoder.encode(book1, withRootKey: "book",
                                      header: XMLHeader(version: 1.0,
                                                        encoding: "UTF-8"))
        let book2 = try decoder.decode(Book.self, from: data)

        XCTAssertEqual(book1, book2)

        // Test string equivalency
        let encodedXML = String(data: data, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalXML = String(data: bookXML, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(encodedXML, originalXML)
    }

    func testCatalogXML() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        decoder.dateDecodingStrategy = .formatted(formatter)
        encoder.dateEncodingStrategy = .formatted(formatter)

        let catalog1 = try decoder.decode(Catalog.self, from: catalogXML)
        XCTAssertEqual(catalog1.books.count, 12)
        XCTAssertEqual(catalog1.books[0].publishDate,
                       Date(timeIntervalSince1970: 970_358_400))

        let data = try encoder.encode(catalog1, withRootKey: "catalog",
                                      header: XMLHeader(version: 1.0,
                                                        encoding: "UTF-8"))
        let catalog2 = try decoder.decode(Catalog.self, from: data)
        XCTAssertEqual(catalog1, catalog2)
    }

    static var allTests = [
        ("testBookXML", testBookXML),
    ]
}
