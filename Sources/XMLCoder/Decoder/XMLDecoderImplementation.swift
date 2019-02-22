//
//  XMLDecoder.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/20/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

class XMLDecoderImplementation: Decoder {
    // MARK: Properties

    /// The decoder's storage.
    var storage: XMLDecodingStorage = XMLDecodingStorage()

    /// Options set on the top-level decoder.
    let options: XMLDecoder.Options

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
    init(referencing container: Box, at codingPath: [CodingKey] = [], options: XMLDecoder.Options) {
        storage.push(container: container)
        self.codingPath = codingPath
        self.options = options
    }

    // MARK: - Decoder Methods

    internal func topContainer() throws -> Box {
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

        guard let keyed = topContainer as? SharedBox<KeyedBox> else {
            throw DecodingError._typeMismatch(
                at: codingPath,
                expectation: [String: Any].self,
                reality: topContainer
            )
        }

        let container = XMLKeyedDecodingContainer<Key>(referencing: self, wrapping: keyed)
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

        let unkeyed = (topContainer as? SharedBox<UnkeyedBox>) ?? SharedBox(UnkeyedBox([topContainer]))

        return XMLUnkeyedDecodingContainer(referencing: self, wrapping: unkeyed)
    }

    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

// MARK: - Concrete Value Representations

extension XMLDecoderImplementation {
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

    private struct TypeMismatch: Error {}

    func unbox<T: Decodable>(_ box: Box) throws -> T {
        let decoded: T?
        let type = T.self

        if type == Date.self || type == NSDate.self {
            let date: Date = try unbox(box)
            decoded = date as? T
        } else if type == Data.self || type == NSData.self {
            let data: Data = try unbox(box)
            decoded = data as? T
        } else if type == URL.self || type == NSURL.self {
            let data: URL = try unbox(box)
            decoded = data as? T
        } else if type == Decimal.self || type == NSDecimalNumber.self {
            let decimal: Decimal = try unbox(box)
            decoded = decimal as? T
        } else if
            type == String.self || type == NSString.self,
            let value = (try unbox(box) as String) as? T {
            decoded = value
        } else {
            storage.push(container: box)
            decoded = try type.init(from: self)
            storage.popContainer()
        }

        guard let result = decoded else {
            throw DecodingError._typeMismatch(
                at: codingPath, expectation: type, reality: box
            )
        }

        return result
    }
}
