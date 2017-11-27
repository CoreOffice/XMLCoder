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

// TEST FUNCTIONS
extension Book {
    static func retrieveBook() -> Book? {
        guard let data = Data(forResource: "book", withExtension: "xml") else { return nil }
        
        let decoder = XMLDecoder()
        
        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let book: Book?
        
        do {
            book = try decoder.decode(Book.self, from: data)
        } catch {
            print(error)
            
            book = nil
        }
        
        return book
    }
    
    func toXML() -> String? {
        let encoder = XMLEncoder()
        
        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        encoder.dateEncodingStrategy = .formatted(formatter)
        
        do {
            let data = try encoder.encode(self, withRootKey: "book", header: XMLHeader(version: 1.0))
            
            return String(data: data, encoding: .utf8)
        } catch {
            print(error)
            
            return nil
        }
    }
}

extension Catalog {
    static func retrieveLibrary() -> Catalog? {
        guard let data = Data(forResource: "books", withExtension: "xml") else { return nil }
        
        let decoder = XMLDecoder()
        
        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let catalog: Catalog?
        
        do {
            catalog = try decoder.decode(Catalog.self, from: data)
        } catch {
            print(error)
            
            catalog = nil
        }
        
        return catalog
    }
    
    func toXML() -> String? {
        let encoder = XMLEncoder()
        
        let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        encoder.dateEncodingStrategy = .formatted(formatter)
        
        do {
            let data = try encoder.encode(self, withRootKey: "catalog", header: XMLHeader(version: 1.0))
            
            return String(data: data, encoding: .utf8)
        } catch {
            print(error)
            
            return nil
        }
    }
}
