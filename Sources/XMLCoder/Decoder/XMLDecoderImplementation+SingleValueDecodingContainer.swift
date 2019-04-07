//
//  XMLDecoder.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/20/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

extension XMLDecoderImplementation: SingleValueDecodingContainer {
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
