//
//  DynamicNodeEncodingTest.swift
//  XMLCoderTests
//
//  Created by Joseph Mattiello on 1/23/19.
//

import Foundation
import XCTest
@testable import XMLCoder

private let libraryXMLYN = """
<?xml version="1.0" encoding="UTF-8"?>
<library count="2">
    <book id="123">
        <id>123</id>
        <title>Cat in the Hat</title>
        <category main="Y"><value>Kids</value></category>
        <category main="N"><value>Wildlife</value></category>
    </book>
    <book id="456">
        <id>789</id>
        <title>1984</title>
        <category main="Y"><value>Classics</value></category>
        <category main="N"><value>News</value></category>
    </book>
</library>
""".data(using: .utf8)!

private let libraryXMLTrueFalse = """
<?xml version="1.0" encoding="UTF-8"?>
<library>
    <count>2</count>
    <book id="123">
        <id>123</id>
        <title>Cat in the Hat</title>
        <category main="true">
            <value>Kids</value>
        </category>
        <category main="false">
            <value>Wildlife</value>
        </category>
    </book>
    <book id="456">
        <id>456</id>
        <title>1984</title>
        <category main="true">
            <value>Classics</value>
        </category>
        <category main="false">
            <value>News</value>
        </category>
    </book>
</library>
"""

private struct Library: Codable, Equatable {
    let count: Int
    let books: [Book]

    private enum CodingKeys: String, CodingKey {
        case count
        case books = "book"
    }
}

private struct Book: Codable, Equatable, DynamicNodeEncoding {
    let id: UInt
    let title: String
    let categories: [Category]

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case categories = "category"
    }

    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case Book.CodingKeys.id: return .both
        default: return .element
        }
    }
}

private struct Category: Codable, Equatable, DynamicNodeEncoding {
    let main: Bool
    let value: String

    private enum CodingKeys: String, CodingKey {
        case main
        case value
    }

    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case Category.CodingKeys.main:
            return .attribute
        default:
            return .element
        }
    }
}

final class DynamicNodeEncodingTest: XCTestCase {
    func testEncode() throws {
        let book1 = Book(id: 123,
                         title: "Cat in the Hat",
                         categories: [
                             Category(main: true, value: "Kids"),
                             Category(main: false, value: "Wildlife"),
        ])

        let book2 = Book(id: 456,
                         title: "1984",
                         categories: [
                             Category(main: true, value: "Classics"),
                             Category(main: false, value: "News"),
        ])

        let library = Library(count: 2, books: [book1, book2])
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]

        let header = XMLHeader(version: 1.0, encoding: "UTF-8")
        let encoded = try encoder.encode(library, withRootKey: "library", header: header)
        let xmlString = String(data: encoded, encoding: .utf8)!
        XCTAssertEqual(xmlString, libraryXMLTrueFalse)
    }

    func testDecode() throws {
        let decoder = XMLDecoder()
        decoder.errorContextLength = 10

        let library = try decoder.decode(Library.self, from: libraryXMLYN)
        XCTAssertEqual(library.books.count, 2)
        XCTAssertEqual(library.count, 2)

        let book1 = library.books[0]
        XCTAssertEqual(book1.id, 123)
        XCTAssertEqual(book1.title, "Cat in the Hat")

        let book1Categories = book1.categories
        XCTAssertEqual(book1Categories.count, 2)
        XCTAssertEqual(book1Categories[0].value, "Kids")
        XCTAssertTrue(book1Categories[0].main)
        XCTAssertEqual(book1Categories[1].value, "Wildlife")
        XCTAssertFalse(book1Categories[1].main)

        let book2 = library.books[1]
        //            XCTAssertEqual(book2.id, 456)
        XCTAssertEqual(book2.title, "1984")

        let book2Categories = book2.categories
        XCTAssertEqual(book2Categories.count, 2)
        XCTAssertEqual(book2Categories[0].value, "Classics")
        XCTAssertTrue(book2Categories[0].main)
        XCTAssertEqual(book2Categories[1].value, "News")
        XCTAssertFalse(book2Categories[1].main)
    }

    func testEncodeDecode() throws {
        let decoder = XMLDecoder()
        decoder.errorContextLength = 10

        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]

        let library = try decoder.decode(Library.self, from: libraryXMLYN)
        XCTAssertEqual(library.books.count, 2)
        XCTAssertEqual(library.count, 2)

        let book1 = library.books[0]
        XCTAssertEqual(book1.id, 123)
        XCTAssertEqual(book1.title, "Cat in the Hat")

        let book1Categories = book1.categories
        XCTAssertEqual(book1Categories.count, 2)
        XCTAssertEqual(book1Categories[0].value, "Kids")
        XCTAssertTrue(book1Categories[0].main)
        XCTAssertEqual(book1Categories[1].value, "Wildlife")
        XCTAssertFalse(book1Categories[1].main)

        let book2 = library.books[1]
        //            XCTAssertEqual(book2.id, 456)
        XCTAssertEqual(book2.title, "1984")

        let book2Categories = book2.categories
        XCTAssertEqual(book2Categories.count, 2)
        XCTAssertEqual(book2Categories[0].value, "Classics")
        XCTAssertTrue(book2Categories[0].main)
        XCTAssertEqual(book2Categories[1].value, "News")
        XCTAssertFalse(book2Categories[1].main)

        let data = try encoder.encode(library, withRootKey: "library",
                                      header: XMLHeader(version: 1.0,
                                                        encoding: "UTF-8"))
        let library2 = try decoder.decode(Library.self, from: data)
        XCTAssertEqual(library, library2)
    }

    static var allTests = [
        ("testEncode", testEncode),
        ("testDecode", testDecode),
        ("testEncodeDecode", testEncodeDecode),
    ]
}
