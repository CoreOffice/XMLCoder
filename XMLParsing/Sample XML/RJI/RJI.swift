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
}

struct Channel: Decodable {
    var title: String
    var link: URL
    var description: String
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
        description = try values.decode(String.self, forKey: .description)
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
    var GUID: URL
    var enclousre: Enclosure
    var description: String
    var subject: String
    var date: Date
    var author: String
}

struct Enclosure: Decodable {
    var url: URL
    var length: String
    var type: String
}
