//
//  ClassTest.swift
//  XMLCoder
//
//  Created by Matvii Hodovaniuk on 1/4/19.
//

import Foundation
import XCTest
@testable import XMLCoder

class A: Codable {
    let x: String
}

class B: A {
    let y: Double

    private enum CodingKeys: CodingKey {
        case y
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        y = try container.decode(Double.self, forKey: .y)
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(y, forKey: .y)
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
}

class C: B {
    let z: Int

    private enum CodingKeys: CodingKey {
        case z
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        z = try container.decode(Int.self, forKey: .z)
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(z, forKey: .z)
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
}

struct S: Codable {
    let a: A
    let b: B
    let c: C
}

let str = "test_string"
let int = 42
let double = 4.2

let xmlData = """
<s>
    <a>
        <x>\(str)</x>
    </a>
    <b>
        <super>
            <x>\(str)</x>
        </super>
        <y>\(double)</y>
    </b>
    <c>
        <super>
            <super>
                <x>\(str)</x>
            </super>
            <y>\(double)</y>
        </super>
        <z>\(int)</z>
    </c>
</s>
""".data(using: .utf8)!

class ClassTests: XCTestCase {
    func testEmpty() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let decoded = try decoder.decode(S.self, from: xmlData)
        XCTAssertEqual(decoded.a.x, str)
        XCTAssertEqual(decoded.b.x, str)
        XCTAssertEqual(decoded.b.y, double)
        XCTAssertEqual(decoded.c.z, int)
        XCTAssertEqual(decoded.c.x, str)
        XCTAssertEqual(decoded.c.y, double)

        let encoded = try encoder.encode(decoded, withRootKey: "s")

        print(NSString(data: encoded, encoding: String.Encoding.utf8.rawValue))
        XCTAssertEqual(encoded, xmlData)
    }

    static var allTests = [
        ("testEmpty", testEmpty),
    ]
}
