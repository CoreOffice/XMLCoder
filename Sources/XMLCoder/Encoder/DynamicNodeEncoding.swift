//
//  DynamicNodeEncoding.swift
//  XMLCoder
//
//  Created by Joseph Mattiello on 1/24/19.
//

import Foundation

public protocol DynamicNodeEncoding: Encodable {
    static func nodeEncoding(forKey key: CodingKey) -> XMLEncoder.NodeEncoding
}

public extension DynamicNodeEncoding {
    static func nodeEncoding(forKey key: CodingKey) -> XMLEncoder.NodeEncoding {
        return XMLEncoder.NodeEncoding.default
    }
}

extension DynamicNodeEncoding where Self: Collection, Self.Iterator.Element: DynamicNodeEncoding {
    public static func nodeEncoding(forKey key: CodingKey) -> XMLEncoder.NodeEncoding {
        return Element.nodeEncoding(forKey: key)
    }
}
