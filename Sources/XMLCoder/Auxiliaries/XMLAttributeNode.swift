//
//  XMLAttribute.swift
//  XMLCoder
//
//  Created by Benjamin Wetherfield on 6/3/20.
//

public protocol XMLAttributeProtocol {}

@propertyWrapper public struct XMLAttributeNode<Value>: XMLAttributeProtocol {
    public var wrappedValue: Value
    
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension XMLAttributeNode: Codable where Value: Codable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        try self.wrappedValue = .init(from: decoder)
    }
}
extension XMLAttributeNode: Equatable where Value: Equatable {}
extension XMLAttributeNode: Hashable where Value: Hashable {}
