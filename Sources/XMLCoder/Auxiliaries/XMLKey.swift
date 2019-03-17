//
//  XMLKey.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/21/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

/// Shared Key Types
struct XMLKey: CodingKey {
    public let stringValue: String
    public let intValue: Int?

    public init?(stringValue: String) {
        self.init(key: stringValue)
    }

    public init?(intValue: Int) {
        self.init(index: intValue)
    }

    public init(stringValue: String, intValue: Int?) {
        self.stringValue = stringValue
        self.intValue = intValue
    }

    init(key: String) {
        self.init(stringValue: key, intValue: nil)
    }

    init(index: Int) {
        self.init(stringValue: "\(index)", intValue: index)
    }

    static let `super` = XMLKey(stringValue: "super")!
}
