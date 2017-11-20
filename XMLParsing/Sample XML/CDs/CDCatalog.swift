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
        case cds = "cds"
    }
}

struct CD: Codable {
    var title: String
    var artist: String
    var country: String
    var company: String
    var price: Double
    var year: Int
}
