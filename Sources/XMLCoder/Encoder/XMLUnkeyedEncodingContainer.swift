//
//  XMLUnkeyedEncodingContainer.swift
//  XMLCoder
//
//  Created by Vincent Esche on 11/20/18.
//

import Foundation

internal struct _XMLUnkeyedEncodingContainer : UnkeyedEncodingContainer {
    // MARK: Properties
    
    /// A reference to the encoder we're writing to.
    private let encoder: _XMLEncoder
    
    /// A reference to the container we're writing to.
    private let container: UnkeyedBox
    
    /// The path of coding keys taken to get to this point in encoding.
    private(set) public var codingPath: [CodingKey]
    
    /// The number of elements encoded into the container.
    public var count: Int {
        return self.container.count
    }
    
    // MARK: - Initialization
    
    /// Initializes `self` with the given references.
    internal init(referencing encoder: _XMLEncoder, codingPath: [CodingKey], wrapping container: UnkeyedBox) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    // MARK: - UnkeyedEncodingContainer Methods
    
    public mutating func encodeNil() throws {
        self.container.append(self.encoder.box())
    }
    
    public mutating func encode(_ value: Bool) throws {
        self.encode(value) { encoder, value in
            return encoder.box(value)
        }
    }
    
    public mutating func encode(_ value: Decimal) throws {
        self.encode(value) { encoder, value in
            return encoder.box(value)
        }
    }
    
    public mutating func encode(_ value: Int) throws {
        try self.encodeSignedInteger(value)
    }
    
    public mutating func encode(_ value: Int8) throws {
        try self.encodeSignedInteger(value)
    }
    
    public mutating func encode(_ value: Int16) throws {
        try self.encodeSignedInteger(value)
    }
    
    public mutating func encode(_ value: Int32) throws {
        try self.encodeSignedInteger(value)
    }
    
    public mutating func encode(_ value: Int64) throws {
        try self.encodeSignedInteger(value)
    }

    public mutating func encode(_ value: UInt) throws {
        try self.encodeUnsignedInteger(value)
    }
    
    public mutating func encode(_ value: UInt8) throws {
        try self.encodeUnsignedInteger(value)
    }
    
    public mutating func encode(_ value: UInt16) throws {
        try self.encodeUnsignedInteger(value)
    }
    
    public mutating func encode(_ value: UInt32) throws {
        try self.encodeUnsignedInteger(value)
    }
    
    public mutating func encode(_ value: UInt64) throws {
        try self.encodeUnsignedInteger(value)
    }
    
    public mutating func encode(_ value: Float) throws {
        try self.encodeFloatingPoint(value)
    }
    
    public mutating func encode(_ value: Double) throws {
        try self.encodeFloatingPoint(value)
    }
    
    public mutating func encode(_ value: String) throws {
        self.encode(value) { encoder, value in
            return encoder.box(value)
        }
    }
    
    public mutating func encode(_ value: Date) throws {
        try self.encode(value) { encoder, value in
            return try encoder.box(value)
        }
    }
    
    public mutating func encode(_ value: Data) throws {
        try self.encode(value) { encoder, value in
            return try encoder.box(value)
        }
    }
    
    private mutating func encodeSignedInteger<T: BinaryInteger & SignedInteger & Encodable>(_ value: T) throws {
        self.encode(value) { encoder, value in
            return encoder.box(value)
        }
    }
    
    private mutating func encodeUnsignedInteger<T: BinaryInteger & UnsignedInteger & Encodable>(_ value: T) throws {
        self.encode(value) { encoder, value in
            return encoder.box(value)
        }
    }
    
    private mutating func encodeFloatingPoint<T: BinaryFloatingPoint & Encodable>(_ value: T)  throws {
        try self.encode(value) { encoder, value in
            return try encoder.box(value)
        }
    }
    
    public mutating func encode<T: Encodable>(_ value: T) throws {
        try self.encode(value) { encoder, value in
            return try encoder.box(value)
        }
    }
    
    private mutating func encode<T: Encodable>(
        _ value: T,
        encode: (_XMLEncoder, T) throws -> (Box)
    ) rethrows {
        self.encoder.codingPath.append(_XMLKey(index: self.count))
        defer { self.encoder.codingPath.removeLast() }
        self.container.append(try encode(self.encoder, value))
    }
    
    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        self.codingPath.append(_XMLKey(index: self.count))
        defer { self.codingPath.removeLast() }
        
        let keyed = KeyedBox()
        self.container.append(keyed)
        
        let container = _XMLKeyedEncodingContainer<NestedKey>(referencing: self.encoder, codingPath: self.codingPath, wrapping: keyed)
        return KeyedEncodingContainer(container)
    }
    
    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self.codingPath.append(_XMLKey(index: self.count))
        defer { self.codingPath.removeLast() }
        
        let unkeyed = UnkeyedBox()
        self.container.append(unkeyed)
        
        return _XMLUnkeyedEncodingContainer(referencing: self.encoder, codingPath: self.codingPath, wrapping: unkeyed)
    }
    
    public mutating func superEncoder() -> Encoder {
        return _XMLReferencingEncoder(referencing: self.encoder, at: self.container.count, wrapping: self.container)
    }
}
