//
//  XMLDecoder.swift
//  XMLParsing
//
//  Created by Shawn Moore on 11/20/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

//===----------------------------------------------------------------------===//
// XML Decoder
//===----------------------------------------------------------------------===//

/// `XMLDecoder` facilitates the decoding of XML into semantic `Decodable` types.
open class XMLDecoder {
    // MARK: Options
    /// The strategy to use for decoding `Date` values.
    public enum DateDecodingStrategy {
        /// Defer to `Date` for decoding. This is the default strategy.
        case deferredToDate
        
        /// Decode the `Date` as a UNIX timestamp from a XML number. This is the default strategy.
        case secondsSince1970
        
        /// Decode the `Date` as UNIX millisecond timestamp from a XML number.
        case millisecondsSince1970
        
        /// Decode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        @available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
        case iso8601
        
        /// Decode the `Date` as a string parsed by the given formatter.
        case formatted(DateFormatter)
        
        /// Decode the `Date` as a custom value decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Date)
        
        /// Decode the `Date` as a string parsed by the given formatter for the give key.
        static func keyFormatted(_ formatterForKey: @escaping (CodingKey) throws -> DateFormatter?) -> XMLDecoder.DateDecodingStrategy {
            return .custom({ (decoder) -> Date in
                guard let codingKey = decoder.codingPath.last else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No Coding Path Found"))
                }
                
                guard let container = try? decoder.singleValueContainer(),
                    let text = try? container.decode(String.self) else {
                        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode date text"))
                }
                
                guard let dateFormatter = try formatterForKey(codingKey) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "No date formatter for date text")
                }
                
                if let date = dateFormatter.date(from: text) {
                    return date
                } else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(text)")
                }
            })
        }
    }
    
    /// The strategy to use for decoding `Data` values.
    public enum DataDecodingStrategy {
        /// Defer to `Data` for decoding.
        case deferredToData
        
        /// Decode the `Data` from a Base64-encoded string. This is the default strategy.
        case base64
        
        /// Decode the `Data` as a custom value decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Data)
        
        /// Decode the `Data` as a custom value by the given closure for the give key.
        static func keyFormatted(_ formatterForKey: @escaping (CodingKey) throws -> Data?) -> XMLDecoder.DataDecodingStrategy {
            return .custom({ (decoder) -> Data in
                guard let codingKey = decoder.codingPath.last else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "No Coding Path Found"))
                }
                
                guard let container = try? decoder.singleValueContainer(),
                    let text = try? container.decode(String.self) else {
                        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode date text"))
                }
                
                guard let data = try formatterForKey(codingKey) else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode data string \(text)")
                }
                
                return data
            })
        }
    }
    
    /// The strategy to use for non-XML-conforming floating-point values (IEEE 754 infinity and NaN).
    public enum NonConformingFloatDecodingStrategy {
        /// Throw upon encountering non-conforming values. This is the default strategy.
        case `throw`
        
        /// Decode the values from the given representation strings.
        case convertFromString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }
    
    /// The strategy to use in decoding dates. Defaults to `.secondsSince1970`.
    open var dateDecodingStrategy: DateDecodingStrategy = .secondsSince1970
    
    /// The strategy to use in decoding binary data. Defaults to `.base64`.
    open var dataDecodingStrategy: DataDecodingStrategy = .base64
    
    /// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
    open var nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw
    
    /// Contextual user-provided information for use during decoding.
    open var userInfo: [CodingUserInfoKey : Any] = [:]
    
    /// Options set on the top-level encoder to pass down the decoding hierarchy.
    internal struct _Options {
        let dateDecodingStrategy: DateDecodingStrategy
        let dataDecodingStrategy: DataDecodingStrategy
        let nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy
        let userInfo: [CodingUserInfoKey : Any]
    }
    
    /// The options set on the top-level decoder.
    internal var options: _Options {
        return _Options(dateDecodingStrategy: dateDecodingStrategy,
                        dataDecodingStrategy: dataDecodingStrategy,
                        nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
                        userInfo: userInfo)
    }
    
    // MARK: - Constructing a XML Decoder
    /// Initializes `self` with default strategies.
    public init() {}
    
    // MARK: - Decoding Values
    /// Decodes a top-level value of the given type from the given XML representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid XML.
    /// - throws: An error if any value throws an error during decoding.
    open func decode<T : Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let topLevel: [String: Any]
        do {
            topLevel = try _XMLStackParser.parse(with: data)
        } catch {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid XML.", underlyingError: error))
        }
        
        let decoder = _XMLDecoder(referencing: topLevel, options: self.options)
        
        guard let value = try decoder.unbox(topLevel, as: type) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value."))
        }
        
        return value
    }
}

// MARK: - _XMLDecoder

internal class _XMLDecoder : Decoder {
    // MARK: Properties
    
    /// The decoder's storage.
    internal var storage: _XMLDecodingStorage
    
    /// Options set on the top-level decoder.
    internal let options: XMLDecoder._Options
    
    /// The path to the current point in encoding.
    internal(set) public var codingPath: [CodingKey]
    
    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey : Any] {
        return self.options.userInfo
    }
    
    // MARK: - Initialization
    
    /// Initializes `self` with the given top-level container and options.
    internal init(referencing container: Any, at codingPath: [CodingKey] = [], options: XMLDecoder._Options) {
        self.storage = _XMLDecodingStorage()
        self.storage.push(container: container)
        self.codingPath = codingPath
        self.options = options
    }
    
    // MARK: - Decoder Methods
    
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard !(self.storage.topContainer is NSNull) else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<Key>.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }
        
        guard let topContainer = self.storage.topContainer as? [String : Any] else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [String : Any].self, reality: self.storage.topContainer)
        }
        
        let container = _XMLKeyedDecodingContainer<Key>(referencing: self, wrapping: topContainer)
        return KeyedDecodingContainer(container)
    }
    
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard !(self.storage.topContainer is NSNull) else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get unkeyed decoding container -- found null value instead."))
        }
        
        let topContainer: [Any]
        
        if let container = self.storage.topContainer as? [Any] {
            topContainer = container
        } else if let container = self.storage.topContainer as? [AnyHashable: Any]  {
            topContainer = [container]
        } else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: [Any].self, reality: self.storage.topContainer)
        }
        
        return _XMLUnkeyedDecodingContainer(referencing: self, wrapping: topContainer)
    }
    
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}


extension _XMLDecoder : SingleValueDecodingContainer {
    // MARK: SingleValueDecodingContainer Methods
    
    private func expectNonNull<T>(_ type: T.Type) throws {
        guard !self.decodeNil() else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }
    }
    
    public func decodeNil() -> Bool {
        return self.storage.topContainer is NSNull
    }
    
    public func decode(_ type: Bool.Type) throws -> Bool {
        try expectNonNull(Bool.self)
        return try self.unbox(self.storage.topContainer, as: Bool.self)!
    }
    
    public func decode(_ type: Int.Type) throws -> Int {
        try expectNonNull(Int.self)
        return try self.unbox(self.storage.topContainer, as: Int.self)!
    }
    
    public func decode(_ type: Int8.Type) throws -> Int8 {
        try expectNonNull(Int8.self)
        return try self.unbox(self.storage.topContainer, as: Int8.self)!
    }
    
    public func decode(_ type: Int16.Type) throws -> Int16 {
        try expectNonNull(Int16.self)
        return try self.unbox(self.storage.topContainer, as: Int16.self)!
    }
    
    public func decode(_ type: Int32.Type) throws -> Int32 {
        try expectNonNull(Int32.self)
        return try self.unbox(self.storage.topContainer, as: Int32.self)!
    }
    
    public func decode(_ type: Int64.Type) throws -> Int64 {
        try expectNonNull(Int64.self)
        return try self.unbox(self.storage.topContainer, as: Int64.self)!
    }
    
    public func decode(_ type: UInt.Type) throws -> UInt {
        try expectNonNull(UInt.self)
        return try self.unbox(self.storage.topContainer, as: UInt.self)!
    }
    
    public func decode(_ type: UInt8.Type) throws -> UInt8 {
        try expectNonNull(UInt8.self)
        return try self.unbox(self.storage.topContainer, as: UInt8.self)!
    }
    
    public func decode(_ type: UInt16.Type) throws -> UInt16 {
        try expectNonNull(UInt16.self)
        return try self.unbox(self.storage.topContainer, as: UInt16.self)!
    }
    
    public func decode(_ type: UInt32.Type) throws -> UInt32 {
        try expectNonNull(UInt32.self)
        return try self.unbox(self.storage.topContainer, as: UInt32.self)!
    }
    
    public func decode(_ type: UInt64.Type) throws -> UInt64 {
        try expectNonNull(UInt64.self)
        return try self.unbox(self.storage.topContainer, as: UInt64.self)!
    }
    
    public func decode(_ type: Float.Type) throws -> Float {
        try expectNonNull(Float.self)
        return try self.unbox(self.storage.topContainer, as: Float.self)!
    }
    
    public func decode(_ type: Double.Type) throws -> Double {
        try expectNonNull(Double.self)
        return try self.unbox(self.storage.topContainer, as: Double.self)!
    }
    
    public func decode(_ type: String.Type) throws -> String {
        try expectNonNull(String.self)
        return try self.unbox(self.storage.topContainer, as: String.self)!
    }
    
    public func decode<T : Decodable>(_ type: T.Type) throws -> T {
        try expectNonNull(type)
        return try self.unbox(self.storage.topContainer, as: type)!
    }
}

// MARK: - Concrete Value Representations

extension _XMLDecoder {
    /// Returns the given value unboxed from a container.
    internal func unbox(_ value: Any, as type: Bool.Type) throws -> Bool? {
        guard !(value is NSNull) else { return nil }
        
        guard let value = value as? String else { return nil }
        
        if value == "true" || value == "1" {
            return true
        } else if value == "false" || value == "0" {
            return false
        }
        
        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }
    
    internal func unbox(_ value: Any, as type: Int.Type) throws -> Int? {
        guard !(value is NSNull) else { return nil }
        
        guard let string = value as? String else { return nil }
        
        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }
        
        let number = NSNumber(value: value)
        
        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let int = number.intValue
        guard NSNumber(value: int) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }
        
        return int
    }
    
    internal func unbox(_ value: Any, as type: Int8.Type) throws -> Int8? {
        guard !(value is NSNull) else { return nil }
        
        guard let string = value as? String else { return nil }
        
        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }
        
        let number = NSNumber(value: value)
        
        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let int8 = number.int8Value
        guard NSNumber(value: int8) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }
        
        return int8
    }
    
    internal func unbox(_ value: Any, as type: Int16.Type) throws -> Int16? {
        guard !(value is NSNull) else { return nil }
        
        guard let string = value as? String else { return nil }
        
        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }
        
        let number = NSNumber(value: value)
        
        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let int16 = number.int16Value
        guard NSNumber(value: int16) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }
        
        return int16
    }
    
    internal func unbox(_ value: Any, as type: Int32.Type) throws -> Int32? {
        guard !(value is NSNull) else { return nil }
        
        guard let string = value as? String else { return nil }
        
        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }
        
        let number = NSNumber(value: value)
        
        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let int32 = number.int32Value
        guard NSNumber(value: int32) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }
        
        return int32
    }
    
    internal func unbox(_ value: Any, as type: Int64.Type) throws -> Int64? {
        guard !(value is NSNull) else { return nil }
        
        guard let string = value as? String else { return nil }
        
        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }
        
        let number = NSNumber(value: value)
        
        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let int64 = number.int64Value
        guard NSNumber(value: int64) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }
        
        return int64
    }
    
    internal func unbox(_ value: Any, as type: UInt.Type) throws -> UInt? {
        guard !(value is NSNull) else { return nil }
        
        guard let string = value as? String else { return nil }
        
        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }
        
        let number = NSNumber(value: value)
        
        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let uint = number.uintValue
        guard NSNumber(value: uint) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }
        
        return uint
    }
    
    internal func unbox(_ value: Any, as type: UInt8.Type) throws -> UInt8? {
        guard !(value is NSNull) else { return nil }
        
        guard let string = value as? String else { return nil }
        
        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }
        
        let number = NSNumber(value: value)
        
        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let uint8 = number.uint8Value
        guard NSNumber(value: uint8) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }
        
        return uint8
    }
    
    internal func unbox(_ value: Any, as type: UInt16.Type) throws -> UInt16? {
        guard !(value is NSNull) else { return nil }
        
        guard let string = value as? String else { return nil }
        
        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }
        
        let number = NSNumber(value: value)
        
        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let uint16 = number.uint16Value
        guard NSNumber(value: uint16) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }
        
        return uint16
    }
    
    internal func unbox(_ value: Any, as type: UInt32.Type) throws -> UInt32? {
        guard !(value is NSNull) else { return nil }
        
        guard let string = value as? String else { return nil }
        
        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }
        
        let number = NSNumber(value: value)
        
        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let uint32 = number.uint32Value
        guard NSNumber(value: uint32) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }
        
        return uint32
    }
    
    internal func unbox(_ value: Any, as type: UInt64.Type) throws -> UInt64? {
        guard !(value is NSNull) else { return nil }
        
        guard let string = value as? String else { return nil }
        
        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: string)
        }
        
        let number = NSNumber(value: value)
        
        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        let uint64 = number.uint64Value
        guard NSNumber(value: uint64) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }
        
        return uint64
    }
    
    internal func unbox(_ value: Any, as type: Float.Type) throws -> Float? {
        guard !(value is NSNull) else { return nil }
        
        guard let string = value as? String else { return nil }
        
        if let value = Double(string) {
            let number = NSNumber(value: value)
            
            guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
            }
            
            let double = number.doubleValue
            guard abs(double) <= Double(Float.greatestFiniteMagnitude) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Parsed XML number \(number) does not fit in \(type)."))
            }
            
            return Float(double)
        } else if case let .convertFromString(posInfString, negInfString, nanString) = self.options.nonConformingFloatDecodingStrategy {
            if string == posInfString {
                return Float.infinity
            } else if string == negInfString {
                return -Float.infinity
            } else if string == nanString {
                return Float.nan
            }
        }
        
        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }
    
    internal func unbox(_ value: Any, as type: Double.Type) throws -> Double? {
        guard !(value is NSNull) else { return nil }
        
        guard let string = value as? String else { return nil }
        
        if let number = Decimal(string: string) as NSDecimalNumber? {
            
            guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
            }
            
            return number.doubleValue
        } else if case let .convertFromString(posInfString, negInfString, nanString) = self.options.nonConformingFloatDecodingStrategy {
            if string == posInfString {
                return Double.infinity
            } else if string == negInfString {
                return -Double.infinity
            } else if string == nanString {
                return Double.nan
            }
        }
        
        throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
    }
    
    internal func unbox(_ value: Any, as type: String.Type) throws -> String? {
        guard !(value is NSNull) else { return nil }
        
        guard let string = value as? String else {
            throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
        }
        
        return string
    }
    
    internal func unbox(_ value: Any, as type: Date.Type) throws -> Date? {
        guard !(value is NSNull) else { return nil }
        
        switch self.options.dateDecodingStrategy {
        case .deferredToDate:
            self.storage.push(container: value)
            let date = try Date(from: self)
            self.storage.popContainer()
            return date
            
        case .secondsSince1970:
            let double = try self.unbox(value, as: Double.self)!
            return Date(timeIntervalSince1970: double)
            
        case .millisecondsSince1970:
            let double = try self.unbox(value, as: Double.self)!
            return Date(timeIntervalSince1970: double / 1000.0)
            
        case .iso8601:
            if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                let string = try self.unbox(value, as: String.self)!
                guard let date = _iso8601Formatter.date(from: string) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
                }
                
                return date
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
            
        case .formatted(let formatter):
            let string = try self.unbox(value, as: String.self)!
            guard let date = formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Date string does not match format expected by formatter."))
            }
            
            return date
            
        case .custom(let closure):
            self.storage.push(container: value)
            let date = try closure(self)
            self.storage.popContainer()
            return date
        }
    }
    
    internal func unbox(_ value: Any, as type: Data.Type) throws -> Data? {
        guard !(value is NSNull) else { return nil }
        
        switch self.options.dataDecodingStrategy {
        case .deferredToData:
            self.storage.push(container: value)
            let data = try Data(from: self)
            self.storage.popContainer()
            return data
            
        case .base64:
            guard let string = value as? String else {
                throw DecodingError._typeMismatch(at: self.codingPath, expectation: type, reality: value)
            }
            
            guard let data = Data(base64Encoded: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath, debugDescription: "Encountered Data is not valid Base64."))
            }
            
            return data
            
        case .custom(let closure):
            self.storage.push(container: value)
            let data = try closure(self)
            self.storage.popContainer()
            return data
        }
    }
    
    internal func unbox(_ value: Any, as type: Decimal.Type) throws -> Decimal? {
        guard !(value is NSNull) else { return nil }
        
        // Attempt to bridge from NSDecimalNumber.
        let doubleValue = try self.unbox(value, as: Double.self)!
        return Decimal(doubleValue)
    }
    
    internal func unbox<T : Decodable>(_ value: Any, as type: T.Type) throws -> T? {
        let decoded: T
        if type == Date.self || type == NSDate.self {
            guard let date = try self.unbox(value, as: Date.self) else { return nil }
            decoded = date as! T
        } else if type == Data.self || type == NSData.self {
            guard let data = try self.unbox(value, as: Data.self) else { return nil }
            decoded = data as! T
        } else if type == URL.self || type == NSURL.self {
            guard let urlString = try self.unbox(value, as: String.self) else {
                return nil
            }
            
            guard let url = URL(string: urlString) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: self.codingPath,
                                                                        debugDescription: "Invalid URL string."))
            }
            
            decoded = (url as! T)
        } else if type == Decimal.self || type == NSDecimalNumber.self {
            guard let decimal = try self.unbox(value, as: Decimal.self) else { return nil }
            decoded = decimal as! T
        } else {
            self.storage.push(container: value)
            decoded = try type.init(from: self)
            self.storage.popContainer()
        }
        
        return decoded
    }
}

