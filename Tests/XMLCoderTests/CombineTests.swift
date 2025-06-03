// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Adam Sharp on 9/29/19.
//

#if canImport(Combine)
import Combine
#elseif canImport(OpenCombine)
import OpenCombine
#endif

#if canImport(Combine) || canImport(OpenCombine)
import Foundation
import XCTest
import XMLCoder

private let xml = """
<?xml version="1.0" encoding="UTF-8"?>
<foo>
    <name>Foo</name>
</foo>
""".data(using: .utf8)!

private struct Foo: Codable {
    var name: String
}

final class CustomEncoder: XMLEncoder {
    override func encode<T>(_ value: T) throws -> Data where T: Encodable {
        return try encode(value, withRootKey: "bar", rootAttributes: nil, header: nil)
    }
}

final class CombineTests: XCTestCase {
    func testDecode() {
        var foo: Foo?
        _ = Just(xml).decode(type: Foo.self, decoder: XMLDecoder()).sink(
            receiveCompletion: { _ in },
            receiveValue: { foo = $0 }
        )
        XCTAssertEqual(foo?.name, "Foo")
    }

    func testEncode() {
        var foo: Foo?
        _ = Just(Foo(name: "Foo"))
            .encode(encoder: XMLEncoder())
            .decode(type: Foo.self, decoder: XMLDecoder())
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    foo = $0
                }
            )
        XCTAssertEqual(foo?.name, "Foo")
    }

    func testCustomEncode() {
        var foo: Data?
        _ = Just(Foo(name: "Foo"))
            .encode(encoder: CustomEncoder())
            .sink(
                receiveCompletion: { _ in },
                receiveValue: {
                    foo = $0
                }
            )
        XCTAssertEqual(
            String(data: foo!, encoding: .utf8)!,
            "<bar><name>Foo</name></bar>"
        )
    }
}
#endif
