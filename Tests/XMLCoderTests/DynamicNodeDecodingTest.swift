//
//  DynamicNodeEncodingTest.swift
//  XMLCoderTests
//
//  Created by Joseph Mattiello on 1/23/19.
//

import Foundation
import XCTest
@testable import XMLCoder

private let overlappingKeys = """
<?xml version="1.0" encoding="UTF-8"?>
<test key="123">
    <key>
        StringValue
    </key>
</test>
""".data(using: .utf8)!

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
""".data(using: .utf8)!

private struct TestStruct: Codable, Equatable, DynamicNodeDecoding {
    let attribute: Int
    let element: String

    private enum CodingKeys: CodingKey {
        case attribute
        case element

        public var stringValue: String {
            return "key"
        }
    }

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
        case CodingKeys.attribute:
            return .attribute
        default:
            return .element
        }
    }
}

private struct Library: Codable, Equatable, DynamicNodeDecoding {
    let count: Int
    let books: [Book]

    enum CodingKeys: String, CodingKey {
        case count
        case books = "book"
    }

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        switch key {
        case CodingKeys.count:
            return .attribute
        default:
            return .element
        }
    }
}

private struct Book: Codable, Equatable, DynamicNodeEncoding {
    let id: UInt
    let author: String
    let gender: String
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

final class DynamicNodeDecodingTest: XCTestCase {
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

    func testStrategyPriority() throws {
        let decoder = XMLDecoder()
        decoder.errorContextLength = 10

        decoder.nodeDecodingStrategy = .custom { type, _ in
            { key in
                guard
                    type == Book.self &&
                    key.stringValue == Book.CodingKeys.title.stringValue
                else {
                    return .element
                }

                return .attribute
            }
        }

        let library = try decoder.decode(Library.self, from: libraryXMLYNStrategy)
        XCTAssertEqual(library.count, 2)
    }

    func testOverlappingKeys() throws {
        let decoder = XMLDecoder()
        decoder.errorContextLength = 10

        let test = try decoder.decode(TestStruct.self, from: overlappingKeys)
        XCTAssertEqual(test, TestStruct(attribute: 123, element: "StringValue"))
    }
}
