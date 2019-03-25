//
//  DynamicNodeDecoding.swift
//  XMLCoder
//
//  Created by Max Desiatov on 01/03/2019.
//

public protocol DynamicNodeDecoding: Decodable {
    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding
}
