//
//  XMLAttribute.swift
//  XMLCoder
//
//  Created by Benjamin Wetherfield on 6/3/20.
//

#if compiler(>=5.1)
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

extension Attribute: ExpressibleByIntegerLiteral where Value: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Value.IntegerLiteralType

    public init(integerLiteral value: Value.IntegerLiteralType) {
        // swiftlint:disable force_cast
        wrappedValue = value as! Value
        // swiftlint:enable force_cast
    }
}

extension Attribute: ExpressibleByUnicodeScalarLiteral where Value: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: Value.UnicodeScalarLiteralType) {
        // swiftlint:disable force_cast
        wrappedValue = value as! Value
        // swiftlint:enable force_cast
    }

    public typealias UnicodeScalarLiteralType = Value.UnicodeScalarLiteralType
}

extension Attribute: ExpressibleByExtendedGraphemeClusterLiteral where Value: ExpressibleByExtendedGraphemeClusterLiteral {
    public typealias ExtendedGraphemeClusterLiteralType = Value.ExtendedGraphemeClusterLiteralType

    public init(extendedGraphemeClusterLiteral value: Value.ExtendedGraphemeClusterLiteralType) {
        // swiftlint:disable force_cast
        wrappedValue = value as! Value
        // swiftlint:enable force_cast
    }
}

extension Attribute: ExpressibleByStringLiteral where Value: ExpressibleByStringLiteral {
    public typealias StringLiteralType = Value.StringLiteralType

    public init(stringLiteral value: Value.StringLiteralType) {
        // swiftlint:disable force_cast
        wrappedValue = value as! Value
        // swiftlint:enable force_cast
    }
}

extension Attribute: ExpressibleByBooleanLiteral where Value: ExpressibleByBooleanLiteral {
    public typealias BooleanLiteralType = Value.BooleanLiteralType

    public init(booleanLiteral value: Value.BooleanLiteralType) {
        // swiftlint:disable force_cast
        wrappedValue = value as! Value
        // swiftlint:enable force_cast
    }
}

//extension Attribute: ExpressibleByNilLiteral where Value: ExpressibleByNilLiteral {
//    public init(nilLiteral: ()) {
//        wrappedValue = nilLiteral as! Value
//    }
//}

protocol XMLOptionalAttributeProtocol: XMLAttributeProtocol {
    init()
}

extension Attribute: XMLOptionalAttributeProtocol where Value: AnyOptional {
    init() {
        wrappedValue = Value.init()
    }
}
#endif
