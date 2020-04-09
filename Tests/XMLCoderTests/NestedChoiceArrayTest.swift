//
//  NestedChoiceArrayTest.swift
//  XMLCoder
//
//  Created by Benjamin Wetherfield on 8/22/19.
//

import XCTest
@testable import XMLCoder

private struct Book: Decodable {
    let title: String
    let chapters: Chapters

    enum CodingKeys: String, CodingKey {
        case title
        case chapters
    }
}

private struct Chapters {
    let items: [Chapter]
}

extension Chapters: Decodable, Equatable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        items = try container.decode([Chapter].self)
    }
}

private enum Chapter {
    struct Content {
        let title: String
        let content: String
    }

    case intro(Content)
    case body(Content)
    case outro(Content)
}

extension Chapter: Decodable {
    enum CodingKeys: String, XMLChoiceCodingKey {
        case intro, body = "chapter", outro
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self = .body(try container.decode(Content.self, forKey: .body))
        } catch {
            do {
                self = .intro(try container.decode(Content.self, forKey: .intro))
            } catch {
                self = .outro(try container.decode(Content.self, forKey: .outro))
            }
        }
    }
}

extension Chapter.Content: Decodable {
    enum CodingKeys: String, CodingKey {
        case title
        case content = ""
    }
}

extension Book: Equatable {}
extension Chapter: Equatable {}
extension Chapter.Content: Equatable {}

final class NestedChoiceArrayTest: XCTestCase {
    func testDecodingNestedChoiceArray() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <book title="Example">
            <chapters>
                <intro title="Intro">Content of first chapter</intro>
                <chapter title="Chapter 1">Content of chapter 1</chapter>
                <chapter title="Chapter 2">Content of chapter 2</chapter>
                <outro title="Epilogue">Content of last chapter</outro>
            </chapters>
        </book>
        """
        let decoded = try XMLDecoder().decode(Book.self, from: xml.data(using: .utf8)!)
        let expected = Book(title: "Example",
                            chapters: Chapters(items: [
                                .intro(.init(title: "Intro", content: "Content of first chapter")),
                                .body(.init(title: "Chapter 1", content: "Content of chapter 1")),
                                .body(.init(title: "Chapter 2", content: "Content of chapter 2")),
                                .outro(.init(title: "Epilogue", content: "Content of last chapter")),
                            ]))
        XCTAssertEqual(decoded, expected)
    }
}
