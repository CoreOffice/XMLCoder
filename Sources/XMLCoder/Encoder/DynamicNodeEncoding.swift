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

extension Array: DynamicNodeEncoding where Element: DynamicNodeEncoding {
    public static func nodeEncoding(forKey key: CodingKey) -> XMLEncoder.NodeEncoding {
        return Element.nodeEncoding(forKey: key)
    }
}

extension DynamicNodeEncoding where Self: Collection, Self.Iterator.Element: DynamicNodeEncoding {
    public static func nodeEncoding(forKey key: CodingKey) -> XMLEncoder.NodeEncoding {
        return Element.nodeEncoding(forKey: key)
    }
}
