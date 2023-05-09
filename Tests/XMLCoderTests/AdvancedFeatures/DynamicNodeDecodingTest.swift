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

private struct TestStruct: Codable, Equatable {
    @Attribute var attribute: Int
    let element: String

    private enum CodingKeys: CodingKey {
        case attribute
        case element

        public var stringValue: String {
            return "key"
        }
    }
}

private struct Library: Codable, Equatable {
    @Attribute var count: Int
    let books: [Book]

    enum CodingKeys: String, CodingKey {
        case count
        case books = "book"
    }
}

private struct Book: Codable, Equatable {
    @ElementAndAttribute var id: UInt
    @ElementAndAttribute var author: String
    @ElementAndAttribute var gender: String
    let title: String
    let categories: [Category]

    enum CodingKeys: String, CodingKey {
        case id
        case author
        case gender
        case title
        case categories = "category"
    }
}

private struct Category: Codable, Equatable {
    @Attribute var main: Bool
    let value: String

    private enum CodingKeys: String, CodingKey {
        case main
        case value
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
    
    func testMissingValues() {
        let xml =
        """
        <Root>
           <nested field1="value_1" />
        </Root>
        """
        
        struct Foo<T: Decodable>: Decodable {
            var nested: T
        }
        
        struct NestedElement: Decodable, DynamicNodeDecoding {
            var field1: String
            var field2: String
            
            static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding { .element }
        }
        
        struct NestedAttribute: Decodable, DynamicNodeDecoding {
            var field1: String
            var field2: String
            
            static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding { .attribute }
        }
        
        struct NestedElementOrAttribute: Decodable, DynamicNodeDecoding {
            var field1: String
            var field2: String
            
            static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding { .elementOrAttribute }
        }
        
        XCTAssertThrowsError(try XMLDecoder().decode(Foo<NestedElement>.self, from: Data(xml.utf8))) {
            guard case DecodingError.keyNotFound = $0 else { XCTFail("Invalid error thrown: \($0)"); return }
        }
        XCTAssertThrowsError(try XMLDecoder().decode(Foo<NestedAttribute>.self, from: Data(xml.utf8))) {
            guard case DecodingError.keyNotFound = $0 else { XCTFail("Invalid error thrown: \($0)"); return }
        }
        XCTAssertThrowsError(try XMLDecoder().decode(Foo<NestedElementOrAttribute>.self, from: Data(xml.utf8))) {
            guard case DecodingError.keyNotFound = $0 else { XCTFail("Invalid error thrown: \($0)"); return }
        }
    }
}
