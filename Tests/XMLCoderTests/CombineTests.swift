//
//  CombineTests.swift
//  XMLCoder
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

@available(iOS 13.0, macOS 10.15.0, tvOS 13.0, watchOS 6.0, *)
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
}
#endif
