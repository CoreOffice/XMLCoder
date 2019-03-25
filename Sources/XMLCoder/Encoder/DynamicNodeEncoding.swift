//
//  DynamicNodeEncoding.swift
//  XMLCoder
//
//  Created by Joseph Mattiello on 1/24/19.
//

public protocol DynamicNodeEncoding: Encodable {
    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding
}

extension Array: DynamicNodeEncoding where Element: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        return Element.nodeEncoding(for: key)
    }
}

extension DynamicNodeEncoding where Self: Collection, Self.Iterator.Element: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        return Element.nodeEncoding(for: key)
    }
}
