//
//  breakfast.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/15/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

struct Menu: Codable {
    var food: [Food]
}

struct Food: Codable {
    var name: String
    var price: String
    var description: String
    var calories: Int?
}

extension Menu {
    static func retrieveMenu() -> Menu? {
        guard let data = Data(forResource: "breakfast", withExtension: "xml") else { return nil }
        
        let decoder = XMLDecoder()
        
        let menu: Menu?
        
        do {
            menu = try decoder.decode(Menu.self, from: data)
        } catch {
            print(error)
            
            menu = nil
        }
        
        return menu
    }
    
    func toXML() -> String? {
        let encoder = XMLEncoder()
        
        do {
            let data = try encoder.encode(self, withRootKey: "breakfast_menu", header: XMLHeader(version: 1.0, encoding: "UTF-8"))
            
            return String(data: data, encoding: .utf8)
        } catch {
            print(error)
            
            return nil
        }
    }
}
