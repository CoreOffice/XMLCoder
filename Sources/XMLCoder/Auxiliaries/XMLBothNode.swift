//
//  XMLBothNode.swift
//  XMLCoder
//
//  Created by Benjamin Wetherfield on 6/7/20.
//

public protocol XMLAttributeElementProtocol {}

@propertyWrapper public struct XMLBothNode<Value>: XMLAttributeElementProtocol {
    public var wrappedValue: Value

    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension XMLBothNode: Codable where Value: Codable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        try wrappedValue = .init(from: decoder)
    }
}

extension XMLBothNode: Equatable where Value: Equatable {}
extension XMLBothNode: Hashable where Value: Hashable {}
