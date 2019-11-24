//
//  IntOrString.swift
//  XMLCoderTests
//
//  Created by Benjamin Wetherfield on 11/24/19.
//

import XMLCoder

internal enum IntOrString: Equatable {
    case int(Int)
    case string(String)
}

extension IntOrString: Codable {
    enum CodingKeys: String, XMLChoiceCodingKey {
        case int
        case string
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .int(value):
            try container.encode(value, forKey: .int)
        case let .string(value):
            try container.encode(value, forKey: .string)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self = .int(try container.decode(Int.self, forKey: .int))
        } catch {
            self = .string(try container.decode(String.self, forKey: .string))
        }
    }
}
