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
        case plants = "PLANT"
    }
}

struct Plant: Codable {
    var common: String
    var botanical: String
    var zone: String
    var light: String
    var price: Double
    var amountAvailable: Int
    
    enum CodingKeys: String, CodingKey {
        case common = "COMMON"
        case botanical = "BOTANICAL"
        case zone = "ZONE"
        case light = "LIGHT"
        case price = "PRICE"
        case amountAvailable = "AVAILABILITY"
    }
    
    init(common: String, botanical: String, zone: String, light: String, price: Double, amountAvailable: Int) {
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
        let zone = try values.decode(String.self, forKey: .zone)
        let light = try values.decode(String.self, forKey: .light)
        let priceString = try values.decode(String.self, forKey: .price)
        let price = Plant.currencyFormatter.number(from: priceString)?.doubleValue ?? 0.0
        let availability = try values.decode(Int.self, forKey: .amountAvailable)
        
        self.init(common: common, botanical: botanical, zone: zone, light: light, price: price, amountAvailable: availability)
    }
}

extension PlantCatalog {
    static func retreievePlantCatalog() -> PlantCatalog? {
        guard let data = Data(forResource: "plant_catalog", withExtension: "xml") else { return nil }
        
        let decoder = XMLDecoder()
        
        let plantCatalog: PlantCatalog?
        
        do {
            plantCatalog = try decoder.decode(PlantCatalog.self, from: data)
        } catch {
            print(error)
            
            plantCatalog = nil
        }
        
        return plantCatalog
    }
    
    func toXML() -> String? {
        let encoder = XMLEncoder()
        
        do {
            let data = try encoder.encode(self, withRootKey: "CATALOG", header: XMLHeader(version: 1.0, encoding: "UTF-8"))
            
            return String(data: data, encoding: .utf8)
        } catch {
            print(error)
            
            return nil
        }
    }
}
