//
//  XMLChoiceCodingKey.swift
//  XMLCoder
//
//  Created by Benjamin Wetherfield on 7/17/19.
//

/// An empty marker protocol that can be used in place of `CodingKey`. It must be used when conforming a union-type–like enum with
/// associated values to `Codable` when the encoded format is `XML`.
public protocol XMLChoiceCodingKey: CodingKey {}
