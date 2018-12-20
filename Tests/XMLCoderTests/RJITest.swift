//
//  RJITest.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 19/11/2018.
//

import Foundation
import XCTest
@testable import XMLCoder

private let itemXML = """
<?xml version="1.0"?>
<item>
    <title>
        <![CDATA[LION Publishers: Journalist develops &#8216;Push&#8217; open source mobile app for small news organizations]]>
    </title>
    <link>https://www.rjionline.org/stories/lion-publishers-journalist-develops-push-open-source-mobile-app-for-small-n</link>
    <guid>https://www.rjionline.org/stories/lion-publishers-journalist-develops-push-open-source-mobile-app-for-small-n</guid>
    <enclosure url="https://www.rjionline.org/images/posts/LION_Pub_logo.png" length="49019" type="image/png" />
    <description>
        <![CDATA[Developer, journalist and RJI Fellow Christopher Guess set out to solve some of the bigger mobile distribution problems of small, online publications.]]>
    </description>
    <dc:subject>
        <![CDATA[Mobile, Presentations, RJI fellowships, Technology,]]>
    </dc:subject>
    <dc:date>2017-10-28T20:33:00+00:00</dc:date>
</item>
""".data(using: .utf8)!

class RJITest: XCTestCase {
    struct RSS: Codable, Equatable {
        let version: String
        let dc: URL
        let sy: URL
        let admin: URL
        let rdf: URL
        let content: URL
        var channel: Channel
        
        enum CodingKeys: String, CodingKey {
            case channel = "channel"
            case version = "version"
            case dc = "xmlns:dc"
            case sy = "xmlns:sy"
            case admin = "xmlns:admin"
            case rdf = "xmlns:rdf"
            case content = "xmlns:content"
        }
    }
    
    struct Channel: Codable, Equatable {
        let title: String
        let link: URL
        let description: String?
        let language: String
        let creator: String
        let rights: String
        let date: Date
        let generatorAgentResource: URL
        let image: Image
        var items: [Item]
        
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
        
        init(title: String,
             link: URL,
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
            self.title = try values.decode(String.self, forKey: .title)
            self.link = try values.decode(URL.self, forKey: .link)
            self.description = try values.decodeIfPresent(String.self, forKey: .description)
            self.language = try values.decode(String.self, forKey: .language)
            self.creator = try values.decode(String.self, forKey: .creator)
            self.rights = try values.decode(String.self, forKey: .rights)
            self.date = try values.decode(Date.self, forKey: .date)
            let generatorAgentValues = try values.nestedContainer(keyedBy: GeneratorAgentKeys.self, forKey: .generatorAgentResource)
            self.generatorAgentResource = try generatorAgentValues.decode(URL.self, forKey: .resource)
            
            self.image = try values.decode(Image.self, forKey: .image)
            self.items = try values.decode([Item].self, forKey: .items)
        }
    }
    
    struct Image: Codable, Equatable {
        let url: URL
        let height: Int
        let width: Int
        let link: URL
        let title: String
    }
    
    struct Item: Codable, Equatable {
        let title: String
        let link: URL
        let guid: URL
        let enclosure: Enclosure?
        let description: String
        let rights: String?
        let subject: String?
        let date: Date?
        let author: String?
        
        enum CodingKeys: String, CodingKey {
            case title, link, guid, enclosure, description
            
            case subject = "dc:subject"
            case date = "dc:date"
            case rights = "dc:rights"
            case author
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            self.title = try values.decode(String.self, forKey: .title)
            self.link = try values.decode(URL.self, forKey: .link)
            self.guid = try values.decode(URL.self, forKey: .guid)
            self.enclosure = try values.decodeIfPresent(Enclosure.self, forKey: .enclosure)
            self.description = try values.decode(String.self, forKey: .description)
            self.rights = try values.decodeIfPresent(String.self, forKey: .rights)
            self.subject = try values.decodeIfPresent(String.self, forKey: .subject)
            self.date = try values.decodeIfPresent(Date.self, forKey: .date)
            self.author = try values.decodeIfPresent(String.self, forKey: .author)
        }
    }
    
    struct Enclosure: Codable, Equatable {
        let url: URL
        let length: String
        let type: String
    }
    
    func testRSS() {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        do {
            let rss1 = try decoder.decode(RSS.self, from: rjiSampleXML)
            
            var testRss = rss1;
            for item in rss1.channel.items{
                testRss.channel.items = [item]
                let data = try encoder.encode(testRss, withRootKey: "rss",
                                          header: XMLHeader(version: 1.0,
                                                            encoding: "UTF-8"))
                let decodedItem = try decoder.decode(RSS.self, from: data)
                XCTAssertEqual(testRss, decodedItem)
            }
        } catch {
            XCTAssert(false, "failed to decode test xml: \(error)")
        }
    }
    
    func testItem() throws{
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        
        let title = try decoder.decode(Item.self, from: itemXML)
        
        do {
            let data = try encoder.encode(title, withRootKey: "item",
                                          header: XMLHeader(version: 1.0,
                                                            encoding: "UTF-8"))
            let decodedItem = try decoder.decode(Item.self, from: data)
            XCTAssertEqual(title, decodedItem)
        } catch {
            XCTAssert(false, "failed to decode test xml: \(error)")
        }
    }
    
    func testBenchmarkRSS() throws {
        let decoder = XMLDecoder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        measure {
            do {
                _ = try decoder.decode(RSS.self, from: rjiSampleXML)
            } catch {
                XCTFail("failed to decode test xml: \(error)")
            }
        }
    }
    
    static var allTests = [
        ("testRSS", testRSS),
        ("testItem", testItem),
        ("testBenchmarkRSS", testBenchmarkRSS),
    ]
}
