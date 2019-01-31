//
//  SOAPSample.swift
//  XMLCoderTests
//
//  Created by Joseph Mattiello on 1/23/19.
//

import Foundation
import XCTest
@testable import XMLCoder

let libraryXML = """
<?xml version="1.0" encoding="UTF-8"?>
<library count="2">
    <book id="123">
        <id>123</id>
        <title>Cat in the Hat</title>
        <category main="Y">Kids</category>
        <category main="N">Wildlife</category>
    </book>
    <book id="456">
        <id>789</id>
        <title>1984</title>
        <category main="Y">Classics</category>
        <category main="N">News</category>
    </book>
</library>
""".data(using: .utf8)!

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

    static func nodeEncoding(forKey key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case Book.CodingKeys.id: return .both
        default: return .element
        }
    }
}

extension Book {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UInt.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)

        var nested = try container.nestedUnkeyedContainer(forKey: .categories)

        var decoded = [Category]()
        var finished = false

        while !finished {
            do {
                 let another = try nested.decode(Category.self)
                decoded.append(another)
            } catch DecodingError.valueNotFound {
                finished = true
            } catch {
                throw error
            }
        }

        categories = decoded
    }
}

private struct Category: Codable, Equatable, DynamicNodeEncoding {
    let main: Bool
    let value: String

    private enum CodingKeys: String, CodingKey {
        case main
        case value = ""
    }

    static func nodeEncoding(forKey key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case Category.CodingKeys.main:
            return .attribute
        default:
            return .element
        }
    }
}

private func decodeArray<T>(_ decoder: Decoder, decode: (inout UnkeyedDecodingContainer) throws -> T) throws -> [T] {
    let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
    var container = try keyedContainer.nestedUnkeyedContainer(forKey: .value)

    var decoded = [T]()
    var finished = false

    while !finished {
        do {
            decoded.append(try decode(&container))
        } catch DecodingError.valueNotFound {
            finished = true
        } catch {
            throw error
        }
    }

    return decoded
}

final class IntrinsicTest: XCTestCase {

    func testEncode() {
        let book1 = Book(id: 123,
                         title: "Cat in the Hat",
                         categories: [
                            Category(main: true, value: "Kids"),
                            Category(main: false, value: "Wildlife")
            ])

        let book2 = Book(id: 456,
                         title: "1984",
                         categories: [
                            Category(main: true, value: "Classics"),
                            Category(main: false, value: "News")
            ])

        let library = Library(count: 2, books: [book1, book2])
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]

        let header = XMLHeader(version: 1.0, encoding: "UTF-8")
        do {
            let encoded = try encoder.encode(library, withRootKey: "library", header: header)
            let xmlString = String(data: encoded, encoding: .utf8)
            XCTAssertNotNil(xmlString)
            print(xmlString!)
        } catch {
            print("Test threw error: " + error.localizedDescription)
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testEncode", testEncode),
        ]
}
