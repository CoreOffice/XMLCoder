//
//  PlantCatalog.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/15/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

struct PlantCatalog {
    var plants: [Plant]
    
    enum CodingKeys: String, CodingKey {
        case plants = "plant"
    }
}

struct Plant: Codable {
    var common: String
    var botanical: String
    var zone: Int
    var light: String
    var price: Double
    var availability: Int
}
