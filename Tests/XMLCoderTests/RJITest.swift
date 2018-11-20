//
//  RJITest.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 19/11/2018.
//

import Foundation
import XCTest
@testable import XMLCoder

class RJITest: XCTestCase {
    struct RSS: Decodable {
        var dc: URL
        var sy: URL
        var admin: URL
        var rdf: URL
        var content: URL
        var channel: Channel
        
        enum CodingKeys: String, CodingKey {
            case channel = "channel"
            
            case dc = "xmlns:dc"
            case sy = "xmlns:sy"
            case admin = "xmlns:admin"
            case rdf = "xmlns:rdf"
            case content = "xmlns:content"
        }
    }
    
    struct Channel: Decodable {
        var title: String
        var link: URL
        var description: String?
        var language: String
        var creator: String
        var rights: String
        var date: Date
        var generatorAgentResource: URL
        var image: Image
        var items: [Item]
        
        enum CodingKeys: String, CodingKey {
            case title, link, description, image
            
            case language = "dc:language"
            case creator = "dc:creator"
            case rights = "dc:rights"
            case date = "dc:date"
            case generatorAgent = "admin:generatorAgent"
            case items = "item"
        }
        
        enum GeneratorAgentKeys: String, CodingKey {
            case resource = "rdf:resource"
        }
        
        init(title: String, link: URL, description: String, language: String, creator: String, rights: String, date: Date, generatorAgentResource: URL, image: Image, items: [Item]) {
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
            self.title = try values.decode(String.self, forKey: .title)
            self.link = try values.decode(URL.self, forKey: .link)
            self.description = try values.decodeIfPresent(String.self, forKey: .description)
            self.language = try values.decode(String.self, forKey: .language)
            self.creator = try values.decode(String.self, forKey: .creator)
            self.rights = try values.decode(String.self, forKey: .rights)
            self.date = try values.decode(Date.self, forKey: .date)
            
            let generatorAgentValues = try values.nestedContainer(keyedBy: GeneratorAgentKeys.self, forKey: .generatorAgent)
            self.generatorAgentResource = try generatorAgentValues.decode(URL.self, forKey: .resource)
            
            self.image = try values.decode(Image.self, forKey: .image)
            self.items = try values.decode([Item].self, forKey: .items)
        }
    }
    
    struct Image: Decodable {
        var url: URL
        var height: Int
        var width: Int
        var link: URL
        var title: String
    }
    
    struct Item: Decodable {
        var title: String
        var link: URL
        var guid: URL
        var enclosure: Enclosure?
        var description: String
        var subject: String?
        var date: Date
        var authors: [String]
        
        enum CodingKeys: String, CodingKey {
            case title, link, guid, enclosure, description
            
            case subject = "dc:subject"
            case date = "dc:date"
            case authors = "author"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            self.title = try values.decode(String.self, forKey: .title)
            self.link = try values.decode(URL.self, forKey: .link)
            self.guid = try values.decode(URL.self, forKey: .guid)
            self.enclosure = try values.decodeIfPresent(Enclosure.self, forKey: .enclosure)
            self.description = try values.decode(String.self, forKey: .description)
            self.subject = try values.decodeIfPresent(String.self, forKey: .subject)
            self.date = try values.decode(Date.self, forKey: .date)
            self.authors = try values.decode([String].self, forKey: .authors)
        }
    }
    
    struct Enclosure: Decodable {
        var url: URL
        var length: String
        var type: String
    }
    
    func testRSS() {
        let decoder = XMLDecoder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        do {
            let bundle = Bundle(for: type(of: self))
            let fileURL = bundle.url(forResource: "RJITest", withExtension: "xml")!
            let data = try Data(contentsOf: fileURL)
            
            let rss = try decoder.decode(RSS.self, from: data)
            
            print("dc: \(rss.dc)")
            print("sy: \(rss.sy)")
            print("admin: \(rss.admin)")
            print("rdf: \(rss.rdf)")
            print("content: \(rss.content)")
            print("channel: \(rss.channel)")
            
            //            let data = try encoder.encode(note1, withRootKey: "note",
            //                                          header: XMLHeader(version: 1.0,
            //                                                            encoding: "UTF-8"))
            //            let note2 = try decoder.decode(Note.self, from: data)
            //            XCTAssertEqual(note1, note2)
        } catch {
            XCTAssert(false, "failed to decode test xml: \(error)")
        }
    }
    
    static var allTests = [
        ("testRSS", testRSS),
    ]
}
