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

        /// Decode the `Date` as a custom box decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Date)

        /// Decode the `Date` as a string parsed by the given formatter for the give key.
        static func keyFormatted(_ formatterForKey: @escaping (CodingKey) throws -> DateFormatter?) -> XMLDecoder.DateDecodingStrategy {
            return .custom({ (decoder) -> Date in
                guard let codingKey = decoder.codingPath.last else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "No Coding Path Found"
                    ))
                }

                guard let container = try? decoder.singleValueContainer(),
                    let text = try? container.decode(String.self) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Could not decode date text"
                    ))
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

        /// Decode the `Data` as a custom box decoded by the given closure.
        case custom((_ decoder: Decoder) throws -> Data)

        /// Decode the `Data` as a custom box by the given closure for the give key.
        static func keyFormatted(_ formatterForKey: @escaping (CodingKey) throws -> Data?) -> XMLDecoder.DataDecodingStrategy {
            return .custom({ (decoder) -> Data in
                guard let codingKey = decoder.codingPath.last else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "No Coding Path Found"
                    ))
                }

                guard let container = try? decoder.singleValueContainer(),
                    let text = try? container.decode(String.self) else {
                    throw DecodingError.dataCorrupted(DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription: "Could not decode date text"
                    ))
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

    /// The strategy to use for automatically changing the box of keys before decoding.
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
        /// If the result of the conversion is a duplicate key, then only one box will be present in the container for the type to decode from.
        case custom((_ codingPath: [CodingKey]) -> CodingKey)

        static func _convertFromCapitalized(_ stringKey: String) -> String {
            guard !stringKey.isEmpty else {
                return stringKey
            }
            var result = stringKey
            let range = result.startIndex...result.index(after: result.startIndex)
            result.replaceSubrange(range, with: result[range].lowercased())
            return result
        }

        static func _convertFromSnakeCase(_ stringKey: String) -> String {
            guard !stringKey.isEmpty else {
                return stringKey
            }

            // Find the first non-underscore character
            guard let firstNonUnderscore = stringKey.index(where: { $0 != "_" }) else {
                // Reached the end without finding an _
                return stringKey
            }

            // Find the last non-underscore character
            var lastNonUnderscore = stringKey.index(before: stringKey.endIndex)
            while lastNonUnderscore > firstNonUnderscore, stringKey[lastNonUnderscore] == "_" {
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
            if leadingUnderscoreRange.isEmpty, trailingUnderscoreRange.isEmpty {
                result = joinedString
            } else if !leadingUnderscoreRange.isEmpty, !trailingUnderscoreRange.isEmpty {
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

    // The error context length
    open var errorContextLength: UInt = 0

    /// Options set on the top-level encoder to pass down the decoding hierarchy.
    struct _Options {
        let dateDecodingStrategy: DateDecodingStrategy
        let dataDecodingStrategy: DataDecodingStrategy
        let nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy
        let keyDecodingStrategy: KeyDecodingStrategy
        let userInfo: [CodingUserInfoKey: Any]
    }

    /// The options set on the top-level decoder.
    var options: _Options {
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

    /// Decodes a top-level box of the given type from the given XML representation.
    ///
    /// - parameter type: The type of the box to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A box of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid XML.
    /// - throws: An error if any box throws an error during decoding.
    open func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let topLevel: Box = try _XMLStackParser.parse(
            with: data,
            errorContextLength: errorContextLength
        )

        let decoder = _XMLDecoder(referencing: topLevel, options: options)

        guard let box: T = try decoder.unbox(topLevel) else {
            throw DecodingError.valueNotFound(type, DecodingError.Context(
                codingPath: [],
                debugDescription: "The given data did not contain a top-level box."
            ))
        }

        return box
    }
}

// MARK: - _XMLDecoder

class _XMLDecoder: Decoder {
    // MARK: Properties

    /// The decoder's storage.
    var storage: _XMLDecodingStorage

    /// Options set on the top-level decoder.
    let options: XMLDecoder._Options

    /// The path to the current point in encoding.
    public internal(set) var codingPath: [CodingKey]

    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey: Any] {
        return options.userInfo
    }

    // The error context lenght
    open var errorContextLenght: UInt = 0

    // MARK: - Initialization

    /// Initializes `self` with the given top-level container and options.
    init(referencing container: Box, at codingPath: [CodingKey] = [], options: XMLDecoder._Options) {
        storage = _XMLDecodingStorage()
        storage.push(container: container)
        self.codingPath = codingPath
        self.options = options
    }

    // MARK: - Decoder Methods

    private func topContainer() throws -> Box {
        guard let topContainer = storage.topContainer() else {
            throw DecodingError.valueNotFound(Box.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get decoding container -- empty container stack."
            ))
        }
        return topContainer
    }

    private func popContainer() throws -> Box {
        guard let topContainer = storage.popContainer() else {
            throw DecodingError.valueNotFound(Box.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get decoding container -- empty container stack."
            ))
        }
        return topContainer
    }

    public func container<Key>(keyedBy _: Key.Type) throws -> KeyedDecodingContainer<Key> {
        let topContainer = try self.topContainer()

        guard !topContainer.isNull else {
            throw DecodingError.valueNotFound(KeyedDecodingContainer<Key>.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get keyed decoding container -- found null box instead."
            ))
        }

        guard let keyed = topContainer as? KeyedBox else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: [String: Any].self, reality: topContainer)
        }

        let container = _XMLKeyedDecodingContainer<Key>(referencing: self, wrapping: keyed)
        return KeyedDecodingContainer(container)
    }

    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let topContainer = try self.topContainer()

        guard !topContainer.isNull else {
            throw DecodingError.valueNotFound(UnkeyedDecodingContainer.self, DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Cannot get unkeyed decoding container -- found null box instead."
            ))
        }

        let unkeyed = (topContainer as? UnkeyedBox) ?? UnkeyedBox([topContainer])

        return _XMLUnkeyedDecodingContainer(referencing: self, wrapping: unkeyed)
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

extension _XMLDecoder: SingleValueDecodingContainer {
    // MARK: SingleValueDecodingContainer Methods

    public func decodeNil() -> Bool {
        return (try? topContainer().isNull) ?? true
    }

    public func decode(_: Bool.Type) throws -> Bool {
        return try unbox(try topContainer())
    }

    public func decode(_: Decimal.Type) throws -> Decimal {
        return try unbox(try topContainer())
    }

    public func decode<T: BinaryInteger & SignedInteger & Decodable>(_: T.Type) throws -> T {
        return try unbox(try topContainer())
    }

    public func decode<T: BinaryInteger & UnsignedInteger & Decodable>(_: T.Type) throws -> T {
        return try unbox(try topContainer())
    }

    public func decode<T: BinaryFloatingPoint & Decodable>(_: T.Type) throws -> T {
        return try unbox(try topContainer())
    }

    public func decode(_: String.Type) throws -> String {
        return try unbox(try topContainer())
    }

    public func decode(_: String.Type) throws -> Date {
        return try unbox(try topContainer())
    }

    public func decode(_: String.Type) throws -> Data {
        return try unbox(try topContainer())
    }

    public func decode<T: Decodable>(_: T.Type) throws -> T {
        return try unbox(try topContainer())
    }
}

// MARK: - Concrete Value Representations

extension _XMLDecoder {
    /// Returns the given box unboxed from a container.
    private func typedBox<T, B: Box>(_ box: Box, for valueType: T.Type) throws -> B {
        guard let typedBox = box as? B else {
            if box is NullBox {
                throw DecodingError.valueNotFound(valueType, DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected \(valueType) but found null instead."
                ))
            } else {
                throw DecodingError._typeMismatch(at: codingPath, expectation: valueType, reality: box)
            }
        }

        return typedBox
    }

    func unbox(_ box: Box) throws -> Bool {
        let stringBox: StringBox = try typedBox(box, for: Bool.self)
        let string = stringBox.unbox()

        guard let boolBox = BoolBox(xmlString: string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: Bool.self, reality: box)
        }

        return boolBox.unbox()
    }

    func unbox(_ box: Box) throws -> Decimal {
        let stringBox: StringBox = try typedBox(box, for: Decimal.self)
        let string = stringBox.unbox()

        guard let decimalBox = DecimalBox(xmlString: string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: Decimal.self, reality: box)
        }

        return decimalBox.unbox()
    }

    func unbox<T: BinaryInteger & SignedInteger & Decodable>(_ box: Box) throws -> T {
        let stringBox: StringBox = try typedBox(box, for: T.self)
        let string = stringBox.unbox()

        guard let intBox = IntBox(xmlString: string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: T.self, reality: box)
        }

        guard let int: T = intBox.unbox() else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Parsed XML number <\(string)> does not fit in \(T.self)."
            ))
        }

        return int
    }

    func unbox<T: BinaryInteger & UnsignedInteger & Decodable>(_ box: Box) throws -> T {
        let stringBox: StringBox = try typedBox(box, for: T.self)
        let string = stringBox.unbox()

        guard let uintBox = UIntBox(xmlString: string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: T.self, reality: box)
        }

        guard let uint: T = uintBox.unbox() else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Parsed XML number <\(string)> does not fit in \(T.self)."
            ))
        }

        return uint
    }

    func unbox<T: BinaryFloatingPoint & Decodable>(_ box: Box) throws -> T {
        let stringBox: StringBox = try typedBox(box, for: T.self)
        let string = stringBox.unbox()

        guard let floatBox = FloatBox(xmlString: string) else {
            throw DecodingError._typeMismatch(at: codingPath, expectation: T.self, reality: box)
        }

        guard let float: T = floatBox.unbox() else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Parsed XML number <\(string)> does not fit in \(T.self)."
            ))
        }

        return float
    }

    func unbox(_ box: Box) throws -> String {
        let stringBox: StringBox = try typedBox(box, for: String.self)
        let string = stringBox.unbox()

        return string
    }

    func unbox(_ box: Box) throws -> Date {
        switch options.dateDecodingStrategy {
        case .deferredToDate:
            storage.push(container: box)
            defer { storage.popContainer() }
            return try Date(from: self)

        case .secondsSince1970:
            let stringBox: StringBox = try typedBox(box, for: Date.self)
            let string = stringBox.unbox()

            guard let dateBox = DateBox(secondsSince1970: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected date string to be formatted in seconds since 1970."
                ))
            }
            return dateBox.unbox()
        case .millisecondsSince1970:
            let stringBox: StringBox = try typedBox(box, for: Date.self)
            let string = stringBox.unbox()

            guard let dateBox = DateBox(millisecondsSince1970: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected date string to be formatted in milliseconds since 1970."
                ))
            }
            return dateBox.unbox()
        case .iso8601:
            let stringBox: StringBox = try typedBox(box, for: Date.self)
            let string = stringBox.unbox()

            guard let dateBox = DateBox(iso8601: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected date string to be ISO8601-formatted."
                ))
            }
            return dateBox.unbox()
        case let .formatted(formatter):
            let stringBox: StringBox = try typedBox(box, for: Date.self)
            let string = stringBox.unbox()

            guard let dateBox = DateBox(xmlString: string, formatter: formatter) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Date string does not match format expected by formatter."
                ))
            }
            return dateBox.unbox()
        case let .custom(closure):
            storage.push(container: box)
            defer { storage.popContainer() }
            return try closure(self)
        }
    }

    func unbox(_ box: Box) throws -> Data {
        switch options.dataDecodingStrategy {
        case .deferredToData:
            storage.push(container: box)
            defer { storage.popContainer() }
            return try Data(from: self)
        case .base64:
            let stringBox: StringBox = try typedBox(box, for: Data.self)
            let string = stringBox.unbox()

            guard let dataBox = DataBox(base64: string) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Encountered Data is not valid Base64"
                ))
            }
            return dataBox.unbox()
        case let .custom(closure):
            storage.push(container: box)
            defer { storage.popContainer() }
            return try closure(self)
        }
    }

    func unbox(_ box: Box) throws -> URL {
        let stringBox: StringBox = try typedBox(box, for: URL.self)
        let string = stringBox.unbox()

        guard let urlBox = URLBox(xmlString: string) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Encountered Data is not valid Base64"
            ))
        }

        return urlBox.unbox()
    }

    func unbox<T: Decodable>(_ box: Box) throws -> T {
        let decoded: T
        let type = T.self

        if type == Date.self || type == NSDate.self {
            let date: Date = try unbox(box)
            decoded = date as! T
        } else if type == Data.self || type == NSData.self {
            let data: Data = try unbox(box)
            decoded = data as! T
        } else if type == URL.self || type == NSURL.self {
            let data: URL = try unbox(box)
            decoded = data as! T
        } else if type == Decimal.self || type == NSDecimalNumber.self {
            let decimal: Decimal = try unbox(box)
            decoded = decimal as! T
        } else {
            storage.push(container: box)
            decoded = try type.init(from: self)
            storage.popContainer()
        }

        return decoded
    }
}
