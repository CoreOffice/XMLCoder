// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Vincent Esche on 12/26/18.
//

import XCTest
@testable import XMLCoder

private struct Foo: Codable {
    var keyedFooBar: String
    var keyedFooBaz: String

    var unkeyedBar0: String
    var unkeyedBar1: String
    var unkeyedBar2: String
    var unkeyedBar3: String

    var singleBlee: String

    init(foo: [String: String], bar: [String], blee: String) {
        keyedFooBar = foo["bar"]!
        keyedFooBaz = foo["baz"]!

        unkeyedBar0 = bar[0]
        unkeyedBar1 = bar[1]
        unkeyedBar2 = bar[2]
        unkeyedBar3 = bar[3]

        singleBlee = blee
    }

    enum FooCodingKeys: String, CodingKey {
        case bar
        case baz
    }

    enum CodingKeys: String, CodingKey {
        case foo
        case bar
        case blee
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        var fooContainer = container.nestedContainer(
            keyedBy: FooCodingKeys.self,
            forKey: .foo
        )

        try fooContainer.encode(keyedFooBar, forKey: .bar)
        try fooContainer.encode(keyedFooBaz, forKey: .baz)

        var barContainer = container.nestedUnkeyedContainer(forKey: .bar)

        try barContainer.encode(unkeyedBar0)
        try barContainer.encode(unkeyedBar1)
        try barContainer.encode(unkeyedBar2)
        try barContainer.encode(unkeyedBar3)

        try container.encode(singleBlee, forKey: .blee)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let fooContainer = try container.nestedContainer(
            keyedBy: FooCodingKeys.self,
            forKey: .foo
        )

        keyedFooBar = try fooContainer.decode(String.self, forKey: .bar)
        keyedFooBaz = try fooContainer.decode(String.self, forKey: .baz)

        var barContainer = try container.nestedUnkeyedContainer(forKey: .bar)

        unkeyedBar0 = try barContainer.decode(String.self)
        unkeyedBar1 = try barContainer.decode(String.self)
        unkeyedBar2 = try barContainer.decode(String.self)
        unkeyedBar3 = try barContainer.decode(String.self)

        singleBlee = try container.decode(String.self, forKey: .blee)
    }
}

final class DecodingContainerTests: XCTestCase {
    func testExample() throws {
        let foo = Foo(
            foo: [
                "bar": "BAR",
                "baz": "BAZ",
            ],
            bar: ["BAR0", "BAR1", "BAR2", "BAR3"],
            blee: "BLEE"
        )

        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        let encoded = try encoder.encode(foo, withRootKey: "foo")

        let decoder = XMLDecoder()
        _ = try decoder.decode(Foo.self, from: encoded)
    }
}
