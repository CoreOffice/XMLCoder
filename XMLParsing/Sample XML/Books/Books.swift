//
//  Books.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/15/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

struct Catalog: Codable {
    var books: [Book]
    
    enum CodingKeys: String, CodingKey {
        case books = "book"
    }
}

struct Book: Codable {
    var id: String
    var author: String
    var title: String
    var genre: Genre
    var price: Double
    var publishDate: Date
    var description: String
    
    enum CodingKeys: String, CodingKey {
        case id, author, title, genre, price, description
        
        case publishDate = "publish_date"
    }
}

enum Genre: String, Codable {
    case computer = "Computer"
    case fantasy = "Fantasy"
    case romance = "Romance"
    case horror = "Horror"
    case sciFi = "Science Fiction"
}
