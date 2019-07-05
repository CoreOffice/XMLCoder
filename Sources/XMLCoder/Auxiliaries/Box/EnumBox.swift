//
//  EnumBox.swift
//  XMLCoder
//
//  Created by Benjamin Wetherfield on 6/30/19.
//

protocol EnumBox: Box {
    
    associatedtype Name: CodingKey
    var name: Name { get }
    
    static func unboxed (as name: Name) -> Box
}

extension EnumBox {
    var isNull: Bool {
        return false
    }
    
    func xmlString() -> String? {
        return Self.unboxed(as: name).xmlString()
    }
}
