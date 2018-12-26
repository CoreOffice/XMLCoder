//
//  NodeCoding.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/25/18.
//

import Foundation

/// A node's coding tyoe
public enum XMLNodeCoding {
    case attribute
    case element

    public static let `default`: XMLNodeCoding = .element
}
