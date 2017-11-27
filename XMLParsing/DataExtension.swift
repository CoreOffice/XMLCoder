//
//  DataExtension.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/26/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

extension Data {
    init?(forResource name: String?, withExtension ext: String?) {
        guard let fileURL = Bundle.main.url(forResource: name, withExtension: ext) else { return nil }
        
        do {
            try self.init(contentsOf: fileURL)
        } catch {
            return nil
        }
    }
}
