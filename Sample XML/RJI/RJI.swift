//
//  RJI.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/20/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

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

extension RSS {
    static func retrieveRSS() -> RSS? {
        guard let data = Data(forResource: "RJI_RSS_Sample", withExtension: "xml") else { return nil }
        
        let decoder = XMLDecoder()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        let rss: RSS?
        
        do {
            rss = try decoder.decode(RSS.self, from: data)
        } catch {
            print(error)
            
            rss = nil
        }
        
        return rss
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
        title = try values.decode(String.self, forKey: .title)
        link = try values.decode(URL.self, forKey: .link)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        language = try values.decode(String.self, forKey: .language)
        creator = try values.decode(String.self, forKey: .creator)
        rights = try values.decode(String.self, forKey: .rights)
        date = try values.decode(Date.self, forKey: .date)
        
        let generatorAgentValues = try values.nestedContainer(keyedBy: GeneratorAgentKeys.self, forKey: .generatorAgent)
        generatorAgentResource = try generatorAgentValues.decode(URL.self, forKey: .resource)
        
        image = try values.decode(Image.self, forKey: .image)
        items = try values.decode([Item].self, forKey: .items)
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
    var author: String?
    
    enum CodingKeys: String, CodingKey {
        case title, link, guid, enclosure, description, author
        
        case subject = "dc:subject"
        case date = "dc:date"
    }
}

struct Enclosure: Decodable {
    var url: URL
    var length: String
    var type: String
}
