//
//  XMLEncoder.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/22/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

//===----------------------------------------------------------------------===//
// XML Encoder
//===----------------------------------------------------------------------===//

/// `XMLEncoder` facilitates the encoding of `Encodable` values into XML.
open class XMLEncoder {
    // MARK: Options

    /// The formatting of the output XML data.
    public struct OutputFormatting: OptionSet {
        /// The format's default value.
        public let rawValue: UInt

        /// Creates an OutputFormatting value with the given raw value.
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        /// Produce human-readable XML with indented output.
        public static let prettyPrinted = OutputFormatting(rawValue: 1 << 0)

        /// Produce XML with dictionary keys sorted in lexicographic order.
        @available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *)
        public static let sortedKeys = OutputFormatting(rawValue: 1 << 1)
    }

    /// A node's encoding tyoe
    public enum NodeEncoding {
        case attribute
        case element

        public static let `default`: NodeEncoding = .element
    }

    /// The strategy to use for encoding `Date` values.
    public enum DateEncodingStrategy {
        /// Defer to `Date` for choosing an encoding. This is the default strategy.
        case deferredToDate

        /// Encode the `Date` as a UNIX timestamp (as a XML number).
        case secondsSince1970

        /// Encode the `Date` as UNIX millisecond timestamp (as a XML number).
        case millisecondsSince1970

        /// Encode the `Date` as an ISO-8601-formatted string (in RFC 3339 format).
        @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
        case iso8601

        /// Encode the `Date` as a string formatted by the given formatter.
        case formatted(DateFormatter)

        /// Encode the `Date` as a custom value encoded by the given closure.
        ///
        /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
        case custom((Date, Encoder) throws -> Void)
    }

    /// The strategy to use for encoding `String` values.
    public enum StringEncodingStrategy {
        /// Defer to `String` for choosing an encoding. This is the default strategy.
        case deferredToString

        /// Encoded the `String` as a CData-encoded string.
        case cdata
    }

    /// The strategy to use for encoding `Data` values.
    public enum DataEncodingStrategy {
        /// Defer to `Data` for choosing an encoding.
        case deferredToData

        /// Encoded the `Data` as a Base64-encoded string. This is the default strategy.
        case base64

        /// Encode the `Data` as a custom value encoded by the given closure.
        ///
        /// If the closure fails to encode a value into the given encoder, the encoder will encode an empty automatic container in its place.
        case custom((Data, Encoder) throws -> Void)
    }

    /// The strategy to use for non-XML-conforming floating-point values (IEEE 754 infinity and NaN).
    public enum NonConformingFloatEncodingStrategy {
        /// Throw upon encountering non-conforming values. This is the default strategy.
        case `throw`

        /// Encode the values using the given representation strings.
        case convertToString(positiveInfinity: String, negativeInfinity: String, nan: String)
    }

    /// The strategy to use for automatically changing the value of keys before encoding.
    public enum KeyEncodingStrategy {
        /// Use the keys specified by each type. This is the default strategy.
        case useDefaultKeys

        /// Convert from "camelCaseKeys" to "snake_case_keys" before writing a key to XML payload.
        ///
        /// Capital characters are determined by testing membership in `CharacterSet.uppercaseLetters` and `CharacterSet.lowercaseLetters` (Unicode General Categories Lu and Lt).
        /// The conversion to lower case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
        ///
        /// Converting from camel case to snake case:
        /// 1. Splits words at the boundary of lower-case to upper-case
        /// 2. Inserts `_` between words
        /// 3. Lowercases the entire string
        /// 4. Preserves starting and ending `_`.
        ///
        /// For example, `oneTwoThree` becomes `one_two_three`. `_oneTwoThree_` becomes `_one_two_three_`.
        ///
        /// - Note: Using a key encoding strategy has a nominal performance cost, as each string key has to be converted.
        case convertToSnakeCase

        /// Provide a custom conversion to the key in the encoded XML from the keys specified by the encoded types.
        /// The full path to the current encoding position is provided for context (in case you need to locate this key within the payload). The returned key is used in place of the last component in the coding path before encoding.
        /// If the result of the conversion is a duplicate key, then only one value will be present in the result.
        case custom((_ codingPath: [CodingKey]) -> CodingKey)

        internal static func _convertToSnakeCase(_ stringKey: String) -> String {
            guard !stringKey.isEmpty else { return stringKey }

            var words: [Range<String.Index>] = []
            // The general idea of this algorithm is to split words on transition from lower to upper case, then on transition of >1 upper case characters to lowercase
            //
            // myProperty -> my_property
            // myURLProperty -> my_url_property
            //
            // We assume, per Swift naming conventions, that the first character of the key is lowercase.
            var wordStart = stringKey.startIndex
            var searchRange = stringKey.index(after: wordStart)..<stringKey.endIndex

            // Find next uppercase character
            while let upperCaseRange = stringKey.rangeOfCharacter(from: CharacterSet.uppercaseLetters, options: [], range: searchRange) {
                let untilUpperCase = wordStart..<upperCaseRange.lowerBound
                words.append(untilUpperCase)

                // Find next lowercase character
                searchRange = upperCaseRange.lowerBound..<searchRange.upperBound
                guard let lowerCaseRange = stringKey.rangeOfCharacter(from: CharacterSet.lowercaseLetters, options: [], range: searchRange) else {
                    // There are no more lower case letters. Just end here.
                    wordStart = searchRange.lowerBound
                    break
                }

                // Is the next lowercase letter more than 1 after the uppercase? If so, we encountered a group of uppercase letters that we should treat as its own word
                let nextCharacterAfterCapital = stringKey.index(after: upperCaseRange.lowerBound)
                if lowerCaseRange.lowerBound == nextCharacterAfterCapital {
                    // The next character after capital is a lower case character and therefore not a word boundary.
                    // Continue searching for the next upper case for the boundary.
                    wordStart = upperCaseRange.lowerBound
                } else {
                    // There was a range of >1 capital letters. Turn those into a word, stopping at the capital before the lower case character.
                    let beforeLowerIndex = stringKey.index(before: lowerCaseRange.lowerBound)
                    words.append(upperCaseRange.lowerBound..<beforeLowerIndex)

                    // Next word starts at the capital before the lowercase we just found
                    wordStart = beforeLowerIndex
                }
                searchRange = lowerCaseRange.upperBound..<searchRange.upperBound
            }
            words.append(wordStart..<searchRange.upperBound)
            let result = words.map({ range in
                stringKey[range].lowercased()
            }).joined(separator: "_")
            return result
        }
    }

    @available(*, deprecated, renamed: "NodeEncodingStrategy")
    public typealias NodeEncodingStrategies = NodeEncodingStrategy

    /// Set of strategies to use for encoding of nodes.
    public enum NodeEncodingStrategy {
        /// Defer to `Encoder` for choosing an encoding. This is the default strategy.
        case deferredToEncoder

        /// Return a closure computing the desired node encoding for the value by its coding key.
        case custom((Encodable.Type, Encoder) -> ((CodingKey) -> XMLEncoder.NodeEncoding))

        internal func nodeEncodings(
            forType codableType: Encodable.Type,
            with encoder: Encoder
        ) -> ((CodingKey) -> XMLEncoder.NodeEncoding) {
            switch self {
            case .deferredToEncoder:
                return { _ in .default }
            case let .custom(closure):
                return closure(codableType, encoder)
            }
        }
    }

    /// The output format to produce. Defaults to `[]`.
    open var outputFormatting: OutputFormatting = []

    /// The strategy to use in encoding dates. Defaults to `.deferredToDate`.
    open var dateEncodingStrategy: DateEncodingStrategy = .deferredToDate

    /// The strategy to use in encoding binary data. Defaults to `.base64`.
    open var dataEncodingStrategy: DataEncodingStrategy = .base64

    /// The strategy to use in encoding non-conforming numbers. Defaults to `.throw`.
    open var nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy = .throw

    /// The strategy to use for encoding keys. Defaults to `.useDefaultKeys`.
    open var keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys

    /// The strategy to use in encoding encoding attributes. Defaults to `.deferredToEncoder`.
    open var nodeEncodingStrategy: NodeEncodingStrategy = .deferredToEncoder

    /// The strategy to use in encoding strings. Defaults to `.deferredToString`.
    open var stringEncodingStrategy: StringEncodingStrategy = .deferredToString

    /// Contextual user-provided information for use during encoding.
    open var userInfo: [CodingUserInfoKey: Any] = [:]

    /// Options set on the top-level encoder to pass down the encoding hierarchy.
    internal struct _Options {
        let dateEncodingStrategy: DateEncodingStrategy
        let dataEncodingStrategy: DataEncodingStrategy
        let nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy
        let keyEncodingStrategy: KeyEncodingStrategy
        let nodeEncodingStrategy: NodeEncodingStrategy
        let stringEncodingStrategy: StringEncodingStrategy
        let userInfo: [CodingUserInfoKey: Any]
    }

    /// The options set on the top-level encoder.
    internal var options: _Options {
        return _Options(dateEncodingStrategy: dateEncodingStrategy,
                        dataEncodingStrategy: dataEncodingStrategy,
                        nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy,
                        keyEncodingStrategy: keyEncodingStrategy,
                        nodeEncodingStrategy: nodeEncodingStrategy,
                        stringEncodingStrategy: stringEncodingStrategy,
                        userInfo: userInfo)
    }

    // MARK: - Constructing a XML Encoder

    /// Initializes `self` with default strategies.
    public init() {}

    // MARK: - Encoding Values

    /// Encodes the given top-level value and returns its XML representation.
    ///
    /// - parameter value: The value to encode.
    /// - parameter withRootKey: the key used to wrap the encoded values.
    /// - returns: A new `Data` value containing the encoded XML data.
    /// - throws: `EncodingError.invalidValue` if a non-conforming floating-point value is encountered during encoding, and the encoding strategy is `.throw`.
    /// - throws: An error if any value throws an error during encoding.
    open func encode<T: Encodable>(_ value: T, withRootKey rootKey: String, header: XMLHeader? = nil) throws -> Data {
        let encoder = _XMLEncoder(
            options: options,
            nodeEncodings: []
        )
        encoder.nodeEncodings.append(options.nodeEncodingStrategy.nodeEncodings(forType: T.self, with: encoder))

        guard let topLevel = try encoder.box_(value) else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) did not encode any values."))
        }

        if topLevel is NSNull {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) encoded as null XML fragment."))
        } else if topLevel is NSNumber {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) encoded as number XML fragment."))
        } else if topLevel is NSString {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Top-level \(T.self) encoded as string XML fragment."))
        }

        guard let element = _XMLElement.createRootElement(rootKey: rootKey, object: topLevel) else {
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Unable to encode the given top-level value to XML."))
        }

        let withCDATA = stringEncodingStrategy != .deferredToString
        return element.toXMLString(with: header, withCDATA: withCDATA, formatting: outputFormatting).data(using: .utf8, allowLossyConversion: true)!
    }
}

internal class _XMLEncoder: Encoder {
    // MARK: Properties

    /// The encoder's storage.
    internal var storage: _XMLEncodingStorage

    /// Options set on the top-level encoder.
    internal let options: XMLEncoder._Options

    /// The path to the current point in encoding.
    public var codingPath: [CodingKey]

    public var nodeEncodings: [(CodingKey) -> XMLEncoder.NodeEncoding]

    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey: Any] {
        return options.userInfo
    }

    // MARK: - Initialization

    /// Initializes `self` with the given top-level encoder options.
    internal init(
        options: XMLEncoder._Options,
        nodeEncodings: [(CodingKey) -> XMLEncoder.NodeEncoding],
        codingPath: [CodingKey] = []
    ) {
        self.options = options
        storage = _XMLEncodingStorage()
        self.codingPath = codingPath
        self.nodeEncodings = nodeEncodings
    }

    /// Returns whether a new element can be encoded at this coding path.
    ///
    /// `true` if an element has not yet been encoded at this coding path; `false` otherwise.
    internal var canEncodeNewValue: Bool {
        // Every time a new value gets encoded, the key it's encoded for is pushed onto the coding path (even if it's a nil key from an unkeyed container).
        // At the same time, every time a container is requested, a new value gets pushed onto the storage stack.
        // If there are more values on the storage stack than on the coding path, it means the value is requesting more than one container, which violates the precondition.
        //
        // This means that anytime something that can request a new container goes onto the stack, we MUST push a key onto the coding path.
        // Things which will not request containers do not need to have the coding path extended for them (but it doesn't matter if it is, because they will not reach here).
        return storage.count == codingPath.count
    }

    // MARK: - Encoder Methods

    public func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> {
        // If an existing keyed container was already requested, return that one.
        let topContainer: NSMutableDictionary
        if canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = storage.pushKeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? NSMutableDictionary else {
                preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
            }

            topContainer = container
        }

        let container = _XMLKeyedEncodingContainer<Key>(referencing: self, codingPath: codingPath, wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        // If an existing unkeyed container was already requested, return that one.
        let topContainer: NSMutableArray
        if canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = storage.pushUnkeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? NSMutableArray else {
                preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
            }

            topContainer = container
        }

        return _XMLUnkeyedEncodingContainer(referencing: self, codingPath: codingPath, wrapping: topContainer)
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

// MARK: - Encoding Containers

fileprivate struct _XMLKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K

    // MARK: Properties

    /// A reference to the encoder we're writing to.
    private let encoder: _XMLEncoder

    /// A reference to the container we're writing to.
    private let container: NSMutableDictionary

    /// The path of coding keys taken to get to this point in encoding.
    public private(set) var codingPath: [CodingKey]

    // MARK: - Initialization

    /// Initializes `self` with the given references.
    fileprivate init(referencing encoder: _XMLEncoder, codingPath: [CodingKey], wrapping container: NSMutableDictionary) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    // MARK: - Coding Path Operations

    private func _converted(_ key: CodingKey) -> CodingKey {
        switch encoder.options.keyEncodingStrategy {
        case .useDefaultKeys:
            return key
        case .convertToSnakeCase:
            let newKeyString = XMLEncoder.KeyEncodingStrategy._convertToSnakeCase(key.stringValue)
            return _XMLKey(stringValue: newKeyString, intValue: key.intValue)
        case let .custom(converter):
            return converter(codingPath + [key])
        }
    }

    // MARK: - KeyedEncodingContainerProtocol Methods

    public mutating func encodeNil(forKey key: Key) throws {
        container[_converted(key).stringValue] = NSNull()
    }

    public mutating func encode(_ value: Bool, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
                container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            container[_converted(key).stringValue] = encoder.box(value)
        }
    }

    public mutating func encode(_ value: Int, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
                container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            container[_converted(key).stringValue] = encoder.box(value)
        }
    }

    public mutating func encode(_ value: Int8, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
                container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            container[_converted(key).stringValue] = encoder.box(value)
        }
    }

    public mutating func encode(_ value: Int16, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
                container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            container[_converted(key).stringValue] = encoder.box(value)
        }
    }

    public mutating func encode(_ value: Int32, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
                container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            container[_converted(key).stringValue] = encoder.box(value)
        }
    }

    public mutating func encode(_ value: Int64, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
                container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            container[_converted(key).stringValue] = encoder.box(value)
        }
    }

    public mutating func encode(_ value: UInt, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
                container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            container[_converted(key).stringValue] = encoder.box(value)
        }
    }

    public mutating func encode(_ value: UInt8, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
                container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            container[_converted(key).stringValue] = encoder.box(value)
        }
    }

    public mutating func encode(_ value: UInt16, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
                container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            container[_converted(key).stringValue] = encoder.box(value)
        }
    }

    public mutating func encode(_ value: UInt32, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
                container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            container[_converted(key).stringValue] = encoder.box(value)
        }
    }

    public mutating func encode(_ value: UInt64, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
                container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            container[_converted(key).stringValue] = encoder.box(value)
        }
    }

    public mutating func encode(_ value: String, forKey key: Key) throws {
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = encoder.box(value)
                container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            container[_converted(key).stringValue] = encoder.box(value)
        }
    }

    public mutating func encode(_ value: Float, forKey key: Key) throws {
        // Since the float may be invalid and throw, the coding path needs to contain this key.
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        container[_converted(key).stringValue] = try encoder.box(value)
    }

    public mutating func encode(_ value: Double, forKey key: Key) throws {
        // Since the double may be invalid and throw, the coding path needs to contain this key.
        encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = try encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = try encoder.box(value)
                container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            container[_converted(key).stringValue] = try encoder.box(value)
        }
    }

    public mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        guard let strategy = self.encoder.nodeEncodings.last else {
            preconditionFailure("Attempt to access node encoding strategy from empty stack.")
        }
        encoder.codingPath.append(key)
        let nodeEncodings = encoder.options.nodeEncodingStrategy.nodeEncodings(
            forType: T.self,
            with: encoder
        )
        encoder.nodeEncodings.append(nodeEncodings)
        defer {
            _ = self.encoder.nodeEncodings.removeLast()
            self.encoder.codingPath.removeLast()
        }
        switch strategy(key) {
        case .attribute:
            if let attributesContainer = self.container[_XMLElement.attributesKey] as? NSMutableDictionary {
                attributesContainer[_converted(key).stringValue] = try encoder.box(value)
            } else {
                let attributesContainer = NSMutableDictionary()
                attributesContainer[_converted(key).stringValue] = try encoder.box(value)
                container[_XMLElement.attributesKey] = attributesContainer
            }
        case .element:
            container[_converted(key).stringValue] = try encoder.box(value)
        }
    }

    public mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let dictionary = NSMutableDictionary()
        self.container[_converted(key).stringValue] = dictionary

        codingPath.append(key)
        defer { self.codingPath.removeLast() }

        let container = _XMLKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let array = NSMutableArray()
        container[_converted(key).stringValue] = array

        codingPath.append(key)
        defer { self.codingPath.removeLast() }
        return _XMLUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: array)
    }

    public mutating func superEncoder() -> Encoder {
        return _XMLReferencingEncoder(referencing: encoder, key: _XMLKey.super, convertedKey: _converted(_XMLKey.super), wrapping: container)
    }

    public mutating func superEncoder(forKey key: Key) -> Encoder {
        return _XMLReferencingEncoder(referencing: encoder, key: key, convertedKey: _converted(key), wrapping: container)
    }
}

fileprivate struct _XMLUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    // MARK: Properties

    /// A reference to the encoder we're writing to.
    private let encoder: _XMLEncoder

    /// A reference to the container we're writing to.
    private let container: NSMutableArray

    /// The path of coding keys taken to get to this point in encoding.
    public private(set) var codingPath: [CodingKey]

    /// The number of elements encoded into the container.
    public var count: Int {
        return container.count
    }

    // MARK: - Initialization

    /// Initializes `self` with the given references.
    fileprivate init(referencing encoder: _XMLEncoder, codingPath: [CodingKey], wrapping container: NSMutableArray) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    // MARK: - UnkeyedEncodingContainer Methods

    public mutating func encodeNil() throws { container.add(NSNull()) }
    public mutating func encode(_ value: Bool) throws { container.add(encoder.box(value)) }
    public mutating func encode(_ value: Int) throws { container.add(encoder.box(value)) }
    public mutating func encode(_ value: Int8) throws { container.add(encoder.box(value)) }
    public mutating func encode(_ value: Int16) throws { container.add(encoder.box(value)) }
    public mutating func encode(_ value: Int32) throws { container.add(encoder.box(value)) }
    public mutating func encode(_ value: Int64) throws { container.add(encoder.box(value)) }
    public mutating func encode(_ value: UInt) throws { container.add(encoder.box(value)) }
    public mutating func encode(_ value: UInt8) throws { container.add(encoder.box(value)) }
    public mutating func encode(_ value: UInt16) throws { container.add(encoder.box(value)) }
    public mutating func encode(_ value: UInt32) throws { container.add(encoder.box(value)) }
    public mutating func encode(_ value: UInt64) throws { container.add(encoder.box(value)) }
    public mutating func encode(_ value: String) throws { container.add(encoder.box(value)) }

    public mutating func encode(_ value: Float) throws {
        // Since the float may be invalid and throw, the coding path needs to contain this key.
        encoder.codingPath.append(_XMLKey(index: count))
        defer { self.encoder.codingPath.removeLast() }
        container.add(try encoder.box(value))
    }

    public mutating func encode(_ value: Double) throws {
        // Since the double may be invalid and throw, the coding path needs to contain this key.
        encoder.codingPath.append(_XMLKey(index: count))
        defer { self.encoder.codingPath.removeLast() }
        container.add(try encoder.box(value))
    }

    public mutating func encode<T: Encodable>(_ value: T) throws {
        encoder.codingPath.append(_XMLKey(index: count))
        let nodeEncodings = encoder.options.nodeEncodingStrategy.nodeEncodings(
            forType: T.self,
            with: encoder
        )
        encoder.nodeEncodings.append(nodeEncodings)
        defer {
            _ = self.encoder.nodeEncodings.removeLast()
            self.encoder.codingPath.removeLast()
        }
        container.add(try encoder.box(value))
    }

    public mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        codingPath.append(_XMLKey(index: count))
        defer { self.codingPath.removeLast() }

        let dictionary = NSMutableDictionary()
        self.container.add(dictionary)

        let container = _XMLKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        codingPath.append(_XMLKey(index: count))
        defer { self.codingPath.removeLast() }

        let array = NSMutableArray()
        container.add(array)
        return _XMLUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: array)
    }

    public mutating func superEncoder() -> Encoder {
        return _XMLReferencingEncoder(referencing: encoder, at: container.count, wrapping: container)
    }
}

extension _XMLEncoder: SingleValueEncodingContainer {
    // MARK: - SingleValueEncodingContainer Methods

    fileprivate func assertCanEncodeNewValue() {
        precondition(canEncodeNewValue, "Attempt to encode value through single value container when previously value already encoded.")
    }

    public func encodeNil() throws {
        assertCanEncodeNewValue()
        storage.push(container: NSNull())
    }

    public func encode(_ value: Bool) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }

    public func encode(_ value: Int) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }

    public func encode(_ value: Int8) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }

    public func encode(_ value: Int16) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }

    public func encode(_ value: Int32) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }

    public func encode(_ value: Int64) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }

    public func encode(_ value: UInt) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }

    public func encode(_ value: UInt8) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }

    public func encode(_ value: UInt16) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }

    public func encode(_ value: UInt32) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }

    public func encode(_ value: UInt64) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }

    public func encode(_ value: String) throws {
        assertCanEncodeNewValue()
        storage.push(container: box(value))
    }

    public func encode(_ value: Float) throws {
        assertCanEncodeNewValue()
        try storage.push(container: box(value))
    }

    public func encode(_ value: Double) throws {
        assertCanEncodeNewValue()
        try storage.push(container: box(value))
    }

    public func encode<T: Encodable>(_ value: T) throws {
        assertCanEncodeNewValue()
        try storage.push(container: box(value))
    }
}

extension _XMLEncoder {
    /// Returns the given value boxed in a container appropriate for pushing onto the container stack.
    fileprivate func box(_ value: Bool) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: Int) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: Int8) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: Int16) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: Int32) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: Int64) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: UInt) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: UInt8) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: UInt16) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: UInt32) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: UInt64) -> NSObject { return NSNumber(value: value) }
    fileprivate func box(_ value: String) -> NSObject { return NSString(string: value) }

    internal func box(_ value: Float) throws -> NSObject {
        if value.isInfinite || value.isNaN {
            guard case let .convertToString(positiveInfinity: posInfString, negativeInfinity: negInfString, nan: nanString) = options.nonConformingFloatEncodingStrategy else {
                throw EncodingError._invalidFloatingPointValue(value, at: codingPath)
            }

            if value == Float.infinity {
                return posInfString as NSObject
            } else if value == -Float.infinity {
                return negInfString as NSObject
            } else {
                return nanString as NSObject
            }
        } else {
            return NSNumber(value: value)
        }
    }

    internal func box(_ value: Double) throws -> NSObject {
        if value.isInfinite || value.isNaN {
            guard case let .convertToString(positiveInfinity: posInfString, negativeInfinity: negInfString, nan: nanString) = options.nonConformingFloatEncodingStrategy else {
                throw EncodingError._invalidFloatingPointValue(value, at: codingPath)
            }

            if value == Double.infinity {
                return posInfString as NSObject
            } else if value == -Double.infinity {
                return negInfString as NSObject
            } else {
                return nanString as NSObject
            }
        } else {
            return NSNumber(value: value)
        }
    }

    internal func box(_ value: Date) throws -> NSObject {
        switch options.dateEncodingStrategy {
        case .deferredToDate:
            try value.encode(to: self)
            return storage.popContainer()
        case .secondsSince1970:
            return NSNumber(value: value.timeIntervalSince1970)
        case .millisecondsSince1970:
            return NSNumber(value: value.timeIntervalSince1970 * 1000.0)
        case .iso8601:
            if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
                return _iso8601Formatter.string(from: value) as NSObject
            } else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }
        case let .formatted(formatter):
            return formatter.string(from: value) as NSObject
        case let .custom(closure):
            let depth = storage.count
            try closure(value, self)

            guard storage.count > depth else { return NSDictionary() }

            return storage.popContainer()
        }
    }

    internal func box(_ value: Data) throws -> NSObject {
        switch options.dataEncodingStrategy {
        case .deferredToData:
            try value.encode(to: self)
            return storage.popContainer()
        case .base64:
            return value.base64EncodedString() as NSObject
        case let .custom(closure):
            let depth = storage.count
            try closure(value, self)

            guard storage.count > depth else { return NSDictionary() }

            return storage.popContainer() as NSObject
        }
    }

    fileprivate func box<T: Encodable>(_ value: T) throws -> NSObject {
        return try box_(value) ?? NSDictionary()
    }

    // This method is called "box_" instead of "box" to disambiguate it from the overloads. Because the return type here is different from all of the "box" overloads (and is more general), any "box" calls in here would call back into "box" recursively instead of calling the appropriate overload, which is not what we want.
    fileprivate func box_<T: Encodable>(_ value: T) throws -> NSObject? {
        if T.self == Date.self || T.self == NSDate.self {
            return try box((value as! Date))
        } else if T.self == Data.self || T.self == NSData.self {
            return try box((value as! Data))
        } else if T.self == URL.self || T.self == NSURL.self {
            return box((value as! URL).absoluteString)
        } else if T.self == Decimal.self || T.self == NSDecimalNumber.self {
            return (value as! NSDecimalNumber)
        }

        let depth = storage.count
        try value.encode(to: self)

        // The top container should be a new container.
        guard storage.count > depth else {
            return nil
        }

        return storage.popContainer()
    }
}
