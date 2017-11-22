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
