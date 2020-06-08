// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Joseph Mattiello on 1/23/19.
//

import Foundation
import XCTest
@testable import XMLCoder

private let libraryXMLYN = """
<?xml version="1.0" encoding="UTF-8"?>
<library count="2">
    <book id="123" author="Jack" gender="novel">
        <id>123</id>
        <author>Jack</author>
        <gender>novel</gender>
        <title>Cat in the Hat</title>
        <category main="Y"><value>Kids</value></category>
        <category main="N"><value>Wildlife</value></category>
    </book>
    <book id="456" author="Susan" gender="fantastic">
        <id>456</id>
        <author>Susan</author>
        <gender>fantastic</gender>
        <title>1984</title>
        <category main="Y"><value>Classics</value></category>
        <category main="N"><value>News</value></category>
    </book>
</library>
""".data(using: .utf8)!

private let libraryXMLYNStrategy = """
<?xml version="1.0" encoding="UTF-8"?>
<library>
    <count>2</count>
    <book title="Cat in the Hat">
        <id>123</id>
        <author>Jack</author>
        <gender>novel</gender>
        <category>
            <main>true</main>
            <value>Kids</value>
        </category>
        <category>
            <main>false</main>
            <value>Wildlife</value>
        </category>
    </book>
    <book title="1984">
        <id>456</id>
        <author>Susan</author>
        <gender>fantastic</gender>
        <category>
            <main>true</main>
            <value>Classics</value>
        </category>
        <category>
            <main>false</main>
            <value>News</value>
        </category>
    </book>
</library>
"""

private let libraryXMLTrueFalse = """
<?xml version="1.0" encoding="UTF-8"?>
<library>
    <count>2</count>
    <book id="123" author="Jack" gender="novel">
        <id>123</id>
        <author>Jack</author>
        <gender>novel</gender>
        <title>Cat in the Hat</title>
        <category main="true">
            <value>Kids</value>
        </category>
        <category main="false">
            <value>Wildlife</value>
        </category>
    </book>
    <book id="456" author="Susan" gender="fantastic">
        <id>456</id>
        <author>Susan</author>
        <gender>fantastic</gender>
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
    @XMLBothNode var id: UInt
    @XMLBothNode var author: String
    @XMLBothNode var gender: String
    let title: String
    let categories: [Category]

    enum CodingKeys: String, CodingKey {
        case id
        case author
        case gender
        case title
        case categories = "category"
    }

    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case Book.CodingKeys.id, Book.CodingKeys.author, Book.CodingKeys.gender: return .both
        default: return .element
        }
    }
}

private struct Category: Codable, Equatable, DynamicNodeEncoding {
    @XMLAttributeNode var main: Bool
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
        let book1 = Book(
            id: .init(123),
            author: .init("Jack"),
            gender: .init("novel"),
            title: "Cat in the Hat",
            categories: [
                Category(main: .init(true), value: "Kids"),
                Category(main: .init(false), value: "Wildlife"),
            ]
        )

        let book2 = Book(
            id: .init(456),
            author: .init("Susan"),
            gender: .init("fantastic"),
            title: "1984",
            categories: [
                Category(main: .init(true), value: "Classics"),
                Category(main: .init(false), value: "News"),
            ]
        )

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
        XCTAssertEqual(book2.id, 456)
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
        XCTAssertEqual(book2.id, 456)
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

    func testStrategyPriority() throws {
        let decoder = XMLDecoder()
        decoder.errorContextLength = 10

        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.nodeEncodingStrategy = .custom { type, _ in
            { key in
                guard
                    type == [Book].self &&
                    key.stringValue == Book.CodingKeys.title.stringValue
                else {
                    return .element
                }

                return .attribute
            }
        }

        let library = try decoder.decode(Library.self, from: libraryXMLYN)
        let data = try encoder.encode(library, withRootKey: "library",
                                      header: XMLHeader(version: 1.0,
                                                        encoding: "UTF-8"))
        XCTAssertEqual(String(data: data, encoding: .utf8)!, libraryXMLYNStrategy)
    }
}
