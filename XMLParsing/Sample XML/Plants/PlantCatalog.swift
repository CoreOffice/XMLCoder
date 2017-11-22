//
//  PlantCatalog.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/15/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

struct PlantCatalog: Codable {
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
    var amountAvailable: Int
    
    enum CodingKeys: String, CodingKey {
        case common, botanical, zone, light, price
        
        case amountAvailable = "availability"
    }
    
    init(common: String, botanical: String, zone: Int, light: String, price: Double, amountAvailable: Int) {
        self.common = common
        self.botanical = botanical
        self.zone = zone
        self.light = light
        self.price = price
        self.amountAvailable = amountAvailable
    }
    
    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let common = try values.decode(String.self, forKey: .common)
        let botanical = try values.decode(String.self, forKey: .botanical)
        let zone = try values.decode(Int.self, forKey: .zone)
        let light = try values.decode(String.self, forKey: .light)
        let priceString = try values.decode(String.self, forKey: .price)
        let price = Plant.currencyFormatter.number(from: priceString)?.doubleValue ?? 0.0
        let availability = try values.decode(Int.self, forKey: .amountAvailable)
        
        self.init(common: common, botanical: botanical, zone: zone, light: light, price: price, amountAvailable: availability)
    }
}
