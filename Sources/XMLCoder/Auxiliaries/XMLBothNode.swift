//
//  XMLBothNode.swift
//  XMLCoder
//
//  Created by Benjamin Wetherfield on 6/7/20.
//

#if swift(>=5.1)
public protocol XMLElementAndAttributeProtocol {}

@propertyWrapper public struct XMLElementAndAttributeNode<Value>: XMLAttributeElementProtocol {
    public var wrappedValue: Value

    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension XMLElementAndAttributeNode: Codable where Value: Codable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        try wrappedValue = .init(from: decoder)
    }
}

extension XMLElementAndAttributeNode: Equatable where Value: Equatable {}
extension XMLElementAndAttributeNode: Hashable where Value: Hashable {}
#endif
