//
//  IntOrStringTest.swift
//  XMLCoderTests
//
//  Created by Benjamin Wetherfield on 7/4/19.
//

private struct Foo: Equatable, Codable {
    let element: IntOrString
    
    public func encode(to encoder: Encoder) throws {
        try element.encode(to: encoder)
    }
    
    public init(from decoder: Decoder) throws {
        element = try IntOrString(from: decoder)
    }
    
    public init(element: IntOrString) {
        self.element = element
    }
}

private enum IntOrString: Equatable, Codable {
    private enum CodingKeys: String, CodingKey {
        case string
        case int
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try values.decodeIfPresent(String.self, forKey: .string) {
            self = .string(value)
            return
        } else if let value = try values.decodeIfPresent(Int.self, forKey: .int) {
            self = .int(value)
            return
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "No coded value for string or int"
            ))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .string(value):
            try container.encode(value, forKey: .string)
        case let .int(value):
            try container.encode(value, forKey: .int)
        }
    }
    
    case string(String)
    case int(Int)
}
