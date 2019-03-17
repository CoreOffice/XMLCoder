//
//  DynamicNodeDecoding.swift
//  XMLCoder
//
//  Created by Max Desiatov on 01/03/2019.
//

public protocol DynamicNodeDecoding: Encodable {
    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding
}

extension Array: DynamicNodeDecoding where Element: DynamicNodeDecoding {
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return Element.nodeDecoding(for: key)
    }
}

extension DynamicNodeDecoding where Self: Collection, Self.Iterator.Element: DynamicNodeDecoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        return Element.nodeDecoding(for: key)
    }
}
