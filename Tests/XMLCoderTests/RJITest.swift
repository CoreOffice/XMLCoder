//
//  RJITest.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 19/11/2018.
//

import Foundation
import XCTest
@testable import XMLCoder

private struct RSS: Codable, Equatable {
    let dc: URL
    let sy: URL
    let admin: URL
    let rdf: URL
    let content: URL
    let channel: Channel

    enum CodingKeys: String, CodingKey {
        case channel

        case dc = "xmlns:dc"
        case sy = "xmlns:sy"
        case admin = "xmlns:admin"
        case rdf = "xmlns:rdf"
        case content = "xmlns:content"
    }
}

private struct GeneratorAgent: Codable, Equatable {
    let resource: URL

    enum CodingKeys: String, CodingKey {
        case resource = "rdf:resource"
    }
}

private struct Channel: Codable, Equatable {
    let title: String
    let link: URL
    let description: String?
    let language: String
    let creator: String
    let rights: String
    let date: Date
    let generatorAgent: GeneratorAgent
    let image: Image
    let items: [Item]

    enum CodingKeys: String, CodingKey {
        case title, link, description, image

        case language = "dc:language"
        case creator = "dc:creator"
        case rights = "dc:rights"
        case date = "dc:date"
        case generatorAgent = "admin:generatorAgent"
        case items = "item"
    }
}

private struct Image: Codable, Equatable {
    let url: URL
    let height: Int
    let width: Int
    let link: URL
    let title: String
}

private struct Item: Codable, Equatable {
    let title: String
    let link: URL
    let guid: URL
    let enclosure: Enclosure?
    let description: String
    let subject: String
    let date: Date
    let author: String?

    enum CodingKeys: String, CodingKey {
        case title, link, guid, enclosure, description

        case subject = "dc:subject"
        case date = "dc:date"
        case author
    }
}

private struct Enclosure: Codable, Equatable {
    let url: URL
    let length: String
    let type: String
}

class RJITest: XCTestCase {
    func testRSS() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        decoder.trimValueWhitespaces = false
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        let rss1 = try decoder.decode(RSS.self, from: rjiSampleXML)
        let data = try encoder.encode(rss1, withRootKey: "note",
                                      header: XMLHeader(version: 1.0,
                                                        encoding: "UTF-8"))

        let rss2 = try decoder.decode(RSS.self, from: data)
        XCTAssertEqual(rss1.channel.items.count, 100)
        XCTAssertEqual(rss2.channel.items.count, 100)

        for (i1, i2) in zip(rss1.channel.items, rss2.channel.items) {
            guard i1 == i2 else {
                XCTFail()
                continue
            }
        }

        XCTAssertEqual(rss1, rss2)
    }
}
