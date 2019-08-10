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
    let chapters: [Chapter]

    enum CodingKeys: String, CodingKey {
        case title
        case chapters
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)

        var chapters = [Chapter]()

        if var chapterContainer = try? container.nestedUnkeyedContainer(forKey: .chapters) {
            while !chapterContainer.isAtEnd {
                chapters.append(try chapterContainer.decode(Chapter.self))
            }
        }

        self.chapters = chapters
    }

    init(title: String, chapters: [Chapter]) {
        self.title = title
        self.chapters = chapters
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

private enum BookError: Error {
    case unknownChapterType
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
        case value = ""
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .value)
    }
}

extension Book: Equatable {}
extension Chapter: Equatable {}
extension Chapter.Content: Equatable {}

class NestedChoiceArrayTest: XCTestCase {
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
                            chapters: [
                                .intro(.init(title: "Intro", content: "Content of first chapter")),
                                .body(.init(title: "Chapter 1", content: "Content of chapter 1")),
                                .body(.init(title: "Chapter 2", content: "Content of chapter 2")),
                                .outro(.init(title: "Epilogue", content: "Content of last chapter")),
                            ])
        XCTAssertEqual(decoded, expected)
    }
}
