//
//  XMLDecoder.swift
//  XMLCoder
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
        @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
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

    /// The strategy to use for automatically changing the value of keys before decoding.
    public enum KeyDecodingStrategy {
        /// Use the keys specified by each type. This is the default strategy.
        case useDefaultKeys

        /// Convert from "snake_case_keys" to "camelCaseKeys" before attempting to match a key with the one specified by each type.
        ///
        /// The conversion to upper case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
        ///
        /// Converting from snake case to camel case:
        /// 1. Capitalizes the word starting after each `_`
        /// 2. Removes all `_`
        /// 3. Preserves starting and ending `_` (as these are often used to indicate private variables or other metadata).
        /// For example, `one_two_three` becomes `oneTwoThree`. `_one_two_three_` becomes `_oneTwoThree_`.
        ///
        /// - Note: Using a key decoding strategy has a nominal performance cost, as each string key has to be inspected for the `_` character.
        case convertFromSnakeCase

        /// Convert from "CodingKey" to "codingKey"
        case convertFromCapitalized

        /// Provide a custom conversion from the key in the encoded XML to the keys specified by the decoded types.
        /// The full path to the current decoding position is provided for context (in case you need to locate this key within the payload). The returned key is used in place of the last component in the coding path before decoding.
        /// If the result of the conversion is a duplicate key, then only one value will be present in the container for the type to decode from.
        case custom((_ codingPath: [CodingKey]) -> CodingKey)

        static func _convertFromCapitalized(_ stringKey: String) -> String {
            guard !stringKey.isEmpty else { return stringKey }
            var result = stringKey
            let range = result.startIndex...result.index(after: result.startIndex)
            result.replaceSubrange(range, with: result[range].lowercased())
            return result
        }

        static func _convertFromSnakeCase(_ stringKey: String) -> String {
            guard !stringKey.isEmpty else { return stringKey }

            // Find the first non-underscore character
            guard let firstNonUnderscore = stringKey.index(where: { $0 != "_" }) else {
                // Reached the end without finding an _
                return stringKey
            }

            // Find the last non-underscore character
            var lastNonUnderscore = stringKey.index(before: stringKey.endIndex)
            while lastNonUnderscore > firstNonUnderscore && stringKey[lastNonUnderscore] == "_" {
                stringKey.formIndex(before: &lastNonUnderscore)
            }

            let keyRange = firstNonUnderscore...lastNonUnderscore
            let leadingUnderscoreRange = stringKey.startIndex..<firstNonUnderscore
            let trailingUnderscoreRange = stringKey.index(after: lastNonUnderscore)..<stringKey.endIndex

            var components = stringKey[keyRange].split(separator: "_")
            let joinedString: String
            if components.count == 1 {
                // No underscores in key, leave the word as is - maybe already camel cased
                joinedString = String(stringKey[keyRange])
            } else {
                joinedString = ([components[0].lowercased()] + components[1...].map { $0.capitalized }).joined()
            }

            // Do a cheap isEmpty check before creating and appending potentially empty strings
            let result: String
            if leadingUnderscoreRange.isEmpty && trailingUnderscoreRange.isEmpty {
                result = joinedString
            } else if !leadingUnderscoreRange.isEmpty && !trailingUnderscoreRange.isEmpty {
                // Both leading and trailing underscores
                result = String(stringKey[leadingUnderscoreRange]) + joinedString + String(stringKey[trailingUnderscoreRange])
            } else if !leadingUnderscoreRange.isEmpty {
                // Just leading
                result = String(stringKey[leadingUnderscoreRange]) + joinedString
            } else {
                // Just trailing
                result = joinedString + String(stringKey[trailingUnderscoreRange])
            }
            return result
        }
    }

    /// The strategy to use in decoding dates. Defaults to `.secondsSince1970`.
    open var dateDecodingStrategy: DateDecodingStrategy = .secondsSince1970

    /// The strategy to use in decoding binary data. Defaults to `.base64`.
    open var dataDecodingStrategy: DataDecodingStrategy = .base64

    /// The strategy to use in decoding non-conforming numbers. Defaults to `.throw`.
    open var nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy = .throw

    /// The strategy to use for decoding keys. Defaults to `.useDefaultKeys`.
    open var keyDecodingStrategy: KeyDecodingStrategy = .useDefaultKeys

    /// Contextual user-provided information for use during decoding.
    open var userInfo: [CodingUserInfoKey: Any] = [:]

    /// Options set on the top-level encoder to pass down the decoding hierarchy.
    internal struct _Options {
        let dateDecodingStrategy: DateDecodingStrategy
        let dataDecodingStrategy: DataDecodingStrategy
        let nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy
        let keyDecodingStrategy: KeyDecodingStrategy
        let userInfo: [CodingUserInfoKey: Any]
    }

    /// The options set on the top-level decoder.
    internal var options: _Options {
        return _Options(dateDecodingStrategy: dateDecodingStrategy,
                        dataDecodingStrategy: dataDecodingStrategy,
                        nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
                        keyDecodingStrategy: keyDecodingStrategy,
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
    open func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let topLevel: [String: Any]
        do {
            topLevel = try _XMLStackParser.parse(with: data)
        } catch {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data was not valid XML.", underlyingError: error))
        }

        let decoder = _XMLDecoder(referencing: topLevel, options: options)

        guard let value = try decoder.unbox(topLevel, as: type) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: [], debugDescription: "The given data did not contain a top-level value."))
        }

        return value
    }
}

// MARK: - _XMLDecoder

internal class _XMLDecoder: Decoder {
    // MARK: Properties

    /// The decoder's storage.
    internal var storage: _XMLDecodingStorage

    /// Options set on the top-level decoder.
    internal let options: XMLDecoder._Options

    /// The path to the current point in encoding.
    public internal(set) var codingPath: [CodingKey]

    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey: Any] {
        return options.userInfo
    }

    // MARK: - Initialization

    /// Initializes `self` with the given top-level container and options.
    internal init(referencing container: Any, at codingPath: [CodingKey] = [], options: XMLDecoder._Options) {
        storage = _XMLDecodingStorage()
        storage.push(container: container)
        self.codingPath = codingPath
        self.options = options
    }

    // MARK: - Decoder Methods

    public func container<Key>(keyedBy _: Key.Type) throws -> KeyedDecodingContainer<Key> {
        guard !(storage.topContainer is NSNull) else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<Key>.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get keyed decoding container -- found null value instead."))
        }

        guard let topContainer = storage.topContainer as? [String: Any] else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [String: Any].self, reality: storage.topContainer)
        }

        let container = _XMLKeyedDecodingContainer<Key>(referencing: self, wrapping: topContainer)
        return KeyedDecodingContainer(container)
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        guard !(storage.topContainer is NSNull) else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Cannot get unkeyed decoding container -- found null value instead."))
        }

        let topContainer: [Any]

        if let container = storage.topContainer as? [Any] {
            topContainer = container
        } else {
            topContainer = [storage.topContainer]
        }

        return _XMLUnkeyedDecodingContainer(referencing: self, wrapping: topContainer)
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

extension _XMLDecoder: SingleValueDecodingContainer {
    // MARK: SingleValueDecodingContainer Methods

    private func expectNonNull<T>(_ type: T.Type) throws {
        guard !decodeNil() else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(type) but found null value instead."))
        }
    }

    public func decodeNil() -> Bool {
        return storage.topContainer is NSNull
    }

    public func decode(_: Bool.Type) throws -> Bool {
        try expectNonNull(Bool.self)
        return try unbox(storage.topContainer, as: Bool.self)!
    }

    public func decode(_: Int.Type) throws -> Int {
        try expectNonNull(Int.self)
        return try unbox(storage.topContainer, as: Int.self)!
    }

    public func decode(_: Int8.Type) throws -> Int8 {
        try expectNonNull(Int8.self)
        return try unbox(storage.topContainer, as: Int8.self)!
    }

    public func decode(_: Int16.Type) throws -> Int16 {
        try expectNonNull(Int16.self)
        return try unbox(storage.topContainer, as: Int16.self)!
    }

    public func decode(_: Int32.Type) throws -> Int32 {
        try expectNonNull(Int32.self)
        return try unbox(storage.topContainer, as: Int32.self)!
    }

    public func decode(_: Int64.Type) throws -> Int64 {
        try expectNonNull(Int64.self)
        return try unbox(storage.topContainer, as: Int64.self)!
    }

    public func decode(_: UInt.Type) throws -> UInt {
        try expectNonNull(UInt.self)
        return try unbox(storage.topContainer, as: UInt.self)!
    }

    public func decode(_: UInt8.Type) throws -> UInt8 {
        try expectNonNull(UInt8.self)
        return try unbox(storage.topContainer, as: UInt8.self)!
    }

    public func decode(_: UInt16.Type) throws -> UInt16 {
        try expectNonNull(UInt16.self)
        return try unbox(storage.topContainer, as: UInt16.self)!
    }

    public func decode(_: UInt32.Type) throws -> UInt32 {
        try expectNonNull(UInt32.self)
        return try unbox(storage.topContainer, as: UInt32.self)!
    }

    public func decode(_: UInt64.Type) throws -> UInt64 {
        try expectNonNull(UInt64.self)
        return try unbox(storage.topContainer, as: UInt64.self)!
    }

    public func decode(_: Float.Type) throws -> Float {
        try expectNonNull(Float.self)
        return try unbox(storage.topContainer, as: Float.self)!
    }

    public func decode(_: Double.Type) throws -> Double {
        try expectNonNull(Double.self)
        return try unbox(storage.topContainer, as: Double.self)!
    }

    public func decode(_: String.Type) throws -> String {
        try expectNonNull(String.self)
        return try unbox(storage.topContainer, as: String.self)!
    }

    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try expectNonNull(type)
        return try unbox(storage.topContainer, as: type)!
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

        throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
    }

    internal func unbox(_ value: Any, as type: Int.Type) throws -> Int? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let int = number.intValue
        guard NSNumber(value: int) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }

        return int
    }

    internal func unbox(_ value: Any, as type: Int8.Type) throws -> Int8? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let int8 = number.int8Value
        guard NSNumber(value: int8) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }

        return int8
    }

    internal func unbox(_ value: Any, as type: Int16.Type) throws -> Int16? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let int16 = number.int16Value
        guard NSNumber(value: int16) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }

        return int16
    }

    internal func unbox(_ value: Any, as type: Int32.Type) throws -> Int32? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let int32 = number.int32Value
        guard NSNumber(value: int32) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }

        return int32
    }

    internal func unbox(_ value: Any, as type: Int64.Type) throws -> Int64? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let int64 = number.int64Value
        guard NSNumber(value: int64) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }

        return int64
    }

    internal func unbox(_ value: Any, as type: UInt.Type) throws -> UInt? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let uint = number.uintValue
        guard NSNumber(value: uint) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }

        return uint
    }

    internal func unbox(_ value: Any, as type: UInt8.Type) throws -> UInt8? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let uint8 = number.uint8Value
        guard NSNumber(value: uint8) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }

        return uint8
    }

    internal func unbox(_ value: Any, as type: UInt16.Type) throws -> UInt16? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let uint16 = number.uint16Value
        guard NSNumber(value: uint16) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }

        return uint16
    }

    internal func unbox(_ value: Any, as type: UInt32.Type) throws -> UInt32? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let uint32 = number.uint32Value
        guard NSNumber(value: uint32) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }

        return uint32
    }

    internal func unbox(_ value: Any, as type: UInt64.Type) throws -> UInt64? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        guard let value = Float(string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: string)
        }

        let number = NSNumber(value: value)

        guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        let uint64 = number.uint64Value
        guard NSNumber(value: uint64) == number else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Parsed XML number <\(number)> does not fit in \(type)."))
        }

        return uint64
    }

    internal func unbox(_ value: Any, as type: Float.Type) throws -> Float? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        if let value = Double(string) {
            let number = NSNumber(value: value)

            guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
            }

            let double = number.doubleValue
            guard abs(double) <= Double(Float.greatestFiniteMagnitude) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Parsed XML number \(number) does not fit in \(type)."))
            }

            return Float(double)
        } else if case let .convertFromString(posInfString, negInfString, nanString) = options.nonConformingFloatDecodingStrategy {
            if string == posInfString {
                return Float.infinity
            } else if string == negInfString {
                return -Float.infinity
            } else if string == nanString {
                return Float.nan
            }
        }

        throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
    }

    internal func unbox(_ value: Any, as type: Double.Type) throws -> Double? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else { return nil }

        if let number = Decimal(string: string) as NSDecimalNumber? {
            guard number !== kCFBooleanTrue, number !== kCFBooleanFalse else {
                throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
            }

            return number.doubleValue
        } else if case let .convertFromString(posInfString, negInfString, nanString) = options.nonConformingFloatDecodingStrategy {
            if string == posInfString {
                return Double.infinity
            } else if string == negInfString {
                return -Double.infinity
            } else if string == nanString {
                return Double.nan
            }
        }

        throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
    }

    internal func unbox(_ value: Any, as type: String.Type) throws -> String? {
        guard !(value is NSNull) else { return nil }

        guard let string = value as? String else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
        }

        return string
    }

    internal func unbox(_ value: Any, as _: Date.Type) throws -> Date? {
        guard !(value is NSNull) else { return nil }

        switch options.dateDecodingStrategy {
        case .deferredToDate:
            storage.push(container: value)
            defer { storage.popContainer() }
            return try Date(from: self)

        case .secondsSince1970:
            let double = try unbox(value, as: Double.self)!
            return Date(timeIntervalSince1970: double)

        case .millisecondsSince1970:
            let double = try unbox(value, as: Double.self)!
            return Date(timeIntervalSince1970: double / 1000.0)

        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                let string = try unbox(value, as: String.self)!
                guard let date = _iso8601Formatter.date(from: string) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
                }

                return date
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }

        case let .formatted(formatter):
            let string = try unbox(value, as: String.self)!
            guard let date = formatter.date(from: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Date string does not match format expected by formatter."))
            }

            return date

        case let .custom(closure):
            storage.push(container: value)
            defer { storage.popContainer() }
            return try closure(self)
        }
    }

    internal func unbox(_ value: Any, as type: Data.Type) throws -> Data? {
        guard !(value is NSNull) else { return nil }

        switch options.dataDecodingStrategy {
        case .deferredToData:
            storage.push(container: value)
            defer { storage.popContainer() }
            return try Data(from: self)

        case .base64:
            guard let string = value as? String else {
                throw DecodingError._typeMismatch(at: codingPath, expectation: type, reality: value)
            }

            guard let data = Data(base64Encoded: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath, debugDescription: "Encountered Data is not valid Base64."))
            }

            return data

        case let .custom(closure):
            storage.push(container: value)
            defer { storage.popContainer() }
            return try closure(self)
        }
    }

    internal func unbox(_ value: Any, as _: Decimal.Type) throws -> Decimal? {
        guard !(value is NSNull) else { return nil }

        // Attempt to bridge from NSDecimalNumber.
        let doubleValue = try unbox(value, as: Double.self)!
        return Decimal(doubleValue)
    }

    internal func unbox<T: Decodable>(_ value: Any, as type: T.Type) throws -> T? {
        let decoded: T
        if type == Date.self || type == NSDate.self {
            guard let date = try unbox(value, as: Date.self) else { return nil }
            decoded = date as! T
        } else if type == Data.self || type == NSData.self {
            guard let data = try unbox(value, as: Data.self) else { return nil }
            decoded = data as! T
        } else if type == URL.self || type == NSURL.self {
            guard let urlString = try unbox(value, as: String.self) else {
                return nil
            }

            guard let url = URL(string: urlString) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: codingPath,
                                                                        debugDescription: "Invalid URL string."))
            }

            decoded = (url as! T)
        } else if type == Decimal.self || type == NSDecimalNumber.self {
            guard let decimal = try unbox(value, as: Decimal.self) else { return nil }
            decoded = decimal as! T
        } else {
            storage.push(container: value)
            defer { storage.popContainer() }
            return try type.init(from: self)
        }

        return decoded
    }
}
