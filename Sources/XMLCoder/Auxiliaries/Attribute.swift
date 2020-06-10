//
//  XMLAttribute.swift
//  XMLCoder
//
//  Created by Benjamin Wetherfield on 6/3/20.
//

#if swift(>=5.1)
public protocol XMLAttributeProtocol {}

@propertyWrapper public struct Attribute<Value>: XMLAttributeProtocol {
    public var wrappedValue: Value

    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
}

extension Attribute: Codable where Value: Codable {
    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        try wrappedValue = .init(from: decoder)
    }
}

extension Attribute: Equatable where Value: Equatable {}
extension Attribute: Hashable where Value: Hashable {}
#endif
