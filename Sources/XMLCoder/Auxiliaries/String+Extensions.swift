//
//  String+Extensions.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/18/18.
//

import Foundation

extension String {
    func escape(_ characterSet: [(character: String, escapedCharacter: String)]) -> String {
        var string = self
        
        for set in characterSet {
            string = string.replacingOccurrences(of: set.character, with: set.escapedCharacter, options: .literal)
        }
        
        return string
    }
}
