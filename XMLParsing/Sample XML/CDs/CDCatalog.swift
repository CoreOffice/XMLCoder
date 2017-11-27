//
//  CDCatalog.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/15/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

struct CDCatalog: Codable {
    var cds: [CD]
    
    enum CodingKeys: String, CodingKey {
        case cds = "CD"
    }
}

struct CD: Codable {
    var title: String
    var artist: String
    var country: String
    var company: String
    var price: Double
    var year: Int
    
    enum CodingKeys: String, CodingKey {
        case title = "TITLE"
        case artist = "ARTIST"
        case country = "COUNTRY"
        case company = "COMPANY"
        case price = "PRICE"
        case year = "YEAR"
    }
}

extension CD {
    static func parseCDCatalog() -> CDCatalog? {
        guard let data = Data(forResource: "cd_catalog", withExtension: "xml") else { return nil }
        
        let decoder = XMLDecoder()
        
        let catalog: CDCatalog?
        
        do {
            catalog = try decoder.decode(CDCatalog.self, from: data)
        } catch {
            print(error)
            
            catalog = nil
        }
        
        return catalog
    }
    
    func toXML() -> String? {
        let encoder = XMLEncoder()
        
        do {
            let data = try encoder.encode(self, withRootKey: "CATALOG", header: XMLHeader(version: 1.0))
            
            return String(data: data, encoding: .utf8)
        } catch {
            print(error)
            
            return nil
        }
    }
}
