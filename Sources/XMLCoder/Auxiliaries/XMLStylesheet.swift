// Copyright (c) 2018-2026 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Mateusz Jabłoński on 06/21/26.
//

import Foundation

/// Type that allows overriding XML stylesheet during encoding. Pass a value of this type to the `encode`
/// function of `XMLEncoder` to specify the exact value of the header you'd like to see in the encoded
/// data.
/// Specification: https://www.w3.org/TR/xml-stylesheet/
public struct XMLStylesheet: Sendable {
    /// Gives the address of the referenced style sheet.
    public let href: String

    /// Gives an advisory media type for the referenced style sheet.
    public let type: String?

    /// Gives the title of the referenced style sheet in a style sheet set.
    public let  title : String?

    public init(href: String, type: String? = nil, title: String? = nil) {
        self.href = href
        self.type = type
        self.title = title
    }

    func toXML() -> String? {
        var string = "<?xml-stylesheet"

        string += " href=\"\(href)\""

        if let type = type {
            string += " type=\"\(type)\""
        }

        if let title = title {
            string += " title=\"\(title)\""
        }

        string += "?>\n"

        return string
    }
}
