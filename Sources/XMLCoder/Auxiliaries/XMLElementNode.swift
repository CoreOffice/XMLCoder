//
//  XMLElementNode.swift
//  XMLCoder
//
//  Created by Benjamin Wetherfield on 6/4/20.
//

#if swift(>=5.1)
protocol XMLElementProtocol {}

@propertyWrapper public struct XMLElementNode<Value>: XMLElementProtocol {
    public var wrappedValue: Value

    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension XMLElementNode: Codable where Value: Codable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        try wrappedValue = .init(from: decoder)
    }
}

extension XMLElementNode: Equatable where Value: Equatable {}
extension XMLElementNode: Hashable where Value: Hashable {}
#endif
