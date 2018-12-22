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

private struct Channel: Codable, Equatable {
    let title: String
    let link: URL
    let description: String?
    let language: String
    let creator: String
    let rights: String
    let date: Date
    let generatorAgentResource: URL
    let image: Image
    let items: [Item]

    enum CodingKeys: String, CodingKey {
        case title, link, description, image

        case language = "dc:language"
        case creator = "dc:creator"
        case rights = "dc:rights"
        case date = "dc:date"
        case generatorAgentResource = "admin:generatorAgent"
        case items = "item"
    }

    enum GeneratorAgentKeys: String, CodingKey {
        case resource = "rdf:resource"
    }

    init(title: String, link: URL,
         description: String,
         language: String,
         creator: String,
         rights: String,
         date: Date,
         generatorAgentResource: URL,
         image: Image,
         items: [Item]) {
        self.title = title
        self.link = link
        self.description = description
        self.language = language
        self.creator = creator
        self.rights = rights
        self.date = date
        self.generatorAgentResource = generatorAgentResource
        self.image = image
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        link = try values.decode(URL.self, forKey: .link)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        language = try values.decode(String.self, forKey: .language)
        creator = try values.decode(String.self, forKey: .creator)
        rights = try values.decode(String.self, forKey: .rights)
        date = try values.decode(Date.self, forKey: .date)

        let generatorAgentValues = try values.nestedContainer(keyedBy: GeneratorAgentKeys.self, forKey: .generatorAgentResource)
        generatorAgentResource = try generatorAgentValues.decode(URL.self, forKey: .resource)

        image = try values.decode(Image.self, forKey: .image)
        items = try values.decode([Item].self, forKey: .items)
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
    let subject: String?
    let date: Date
    let author: String?

    enum CodingKeys: String, CodingKey {
        case title, link, guid, enclosure, description

        case subject = "dc:subject"
        case date = "dc:date"
        case author
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        title = try values.decode(String.self, forKey: .title)
        link = try values.decode(URL.self, forKey: .link)
        guid = try values.decode(URL.self, forKey: .guid)
        enclosure = try values.decodeIfPresent(Enclosure.self, forKey: .enclosure)
        description = try values.decode(String.self, forKey: .description)
        subject = try values.decodeIfPresent(String.self, forKey: .subject)
        date = try values.decode(Date.self, forKey: .date)
        author = try values.decodeIfPresent(String.self, forKey: .author)
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
//        let encoder = XMLEncoder()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

//        let rss1
        _ = try decoder.decode(RSS.self, from: rjiSampleXML)
        // this is a very peculiar case of `XMLCoder` not being able to decode an XML
        // that it itself encoded
//        data = try encoder.encode(rss1, withRootKey: "note",
//                                  header: XMLHeader(version: 1.0,
//                                                    encoding: "UTF-8"))
//        let rss2 = try decoder.decode(RSS.self, from: data)
//        XCTAssertEqual(rss1, rss2)
    }

    static var allTests = [
        ("testRSS", testRSS),
    ]
}
