//
//  String+Extensions.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/18/18.
//

import Foundation

extension StringProtocol where Self.Index == String.Index  {
    func escape(_ characterSet: [(character: String, escapedCharacter: String)]) -> String {
        var string = String(self)

        for set in characterSet {
            string = string.replacingOccurrences(of: set.character, with: set.escapedCharacter, options: .literal)
        }

        return string
    }
}

extension StringProtocol {
    func capitalizingFirstLetter() -> Self {
        guard count > 1 else {
            return self
        }
        return Self(prefix(1).uppercased() + self.dropFirst())!
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }

    func lowercasingFirstLetter() -> Self {
        // avoid lowercasing single letters (I), or capitalized multiples (AThing ! to aThing, leave as AThing)
        guard count > 1 && !(String(prefix(2)) == prefix(2).uppercased()) else {
            return self
        }
        return Self(prefix(1).lowercased() + self.dropFirst())!
    }

    mutating func lowercaseFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
