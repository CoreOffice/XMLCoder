//
//  RJI.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/20/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

struct RSS: Codable {
    var dc: URL
    var sy: URL
    var admin: URL
    var rdf: URL
    var content: URL
    var channel: Channel
}

struct Channel: Codable {
    var title: String
    var link: URL
    var description: String
    var language: String
    var creator: String
    var rights: String
    var date: Date
    var generatorAgent: GeneratorAgent
    var image: Image
    var item: [Item]
}

struct GeneratorAgent: Codable {
    var resource: URL
}

struct Image: Codable {
    var url: URL
    var height: Int
    var width: Int
    var link: URL
    var title: String
}

struct Item: Codable {
    var title: String
    var link: URL
    var GUID: URL
    var enclousre: Enclosure
    var description: String
    var subject: String
    var date: Date
    var author: String
}

struct Enclosure: Codable {
    var url: URL
    var length: String
    var type: String
}
