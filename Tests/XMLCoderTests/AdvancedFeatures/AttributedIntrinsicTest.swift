// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Joseph Mattiello on 1/23/19.
//

import Foundation
import XCTest
@testable import XMLCoder

let fooXML = """
<?xml version="1.0" encoding="UTF-8"?>
<foo id="123">456</foo>
""".data(using: .utf8)!

let fooArrayXML = """
<?xml version="1.0" encoding="UTF-8"?>
<container>
<foo id="123">456</foo>
<foo id="789">123</foo>
</container>
""".data(using: .utf8)!

let fooMixedXML = """
<?xml version="1.0" encoding="UTF-8"?>
<container>
<foo id="123">456</foo>
<foo id="789">123</foo>
<foo>789</foo>
</container>
""".data(using: .utf8)!

let fooValueXML = """
<?xml version="1.0" encoding="UTF-8"?>
<container>
<foo>456</foo>
<foo>123</foo>
<foo>789</foo>
</container>
""".data(using: .utf8)!

let fooValueAttributeXML = """
<foo value="blah">456</foo>
""".data(using: .utf8)!

let fooValueElementXML = """
<foo><value>blah</value></foo>
""".data(using: .utf8)!

private struct FooValueAttribute: Codable, DynamicNodeDecoding {
    let valueAttribute: String
    let value: Int

    enum CodingKeys: String, CodingKey {
        case valueAttribute = "value"
        case value = ""
    }

    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        guard key.stringValue == CodingKeys.valueAttribute.stringValue else {
            return .element
        }

        return .attribute
    }
}

private struct FooValueElement: Codable {
    let valueElement: String
    let value: Int?

    enum CodingKeys: String, CodingKey {
        case valueElement = "value"
        case value = ""
    }
}

private struct Foo: Codable, DynamicNodeEncoding, Equatable {
    let id: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case id
        case value = ""
    }

    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case CodingKeys.id:
            return .attribute
        default:
            return .element
        }
    }
}

private struct FooValue: Codable, Equatable {
    let value: Int

    enum CodingKeys: String, CodingKey {
        case value = ""
    }
}

private struct FooOptional: Codable, DynamicNodeEncoding, Equatable {
    let id: String?
    let value: Int

    enum CodingKeys: String, CodingKey {
        case id
        case value = ""
    }

    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case CodingKeys.id:
            return .attribute
        default:
            return .element
        }
    }
}

private struct FooEmptyKeyed: Codable, DynamicNodeEncoding, Equatable {
    @XMLAttributeNode var id: String
    let unkeyedValue: Int

    enum CodingKeys: String, CodingKey {
        case id
        case unkeyedValue = ""
    }

    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case CodingKeys.id:
            return .attribute
        default:
            return .element
        }
    }
}

private struct Container<T>: Codable, Equatable where T: Codable & Equatable {
    let foo: [T]
}

private let previewXML =
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <app_preview display_target="iOS-6.5-in" position="1">
    <preview_image_time format="24/999 1000/nonDrop">00:00:17:01</preview_image_time>
    </app_preview>
    """.data(using: .utf8)!

private struct AppPreview: Codable, Equatable {
    var displayTarget: String
    var position: Int
    var previewImageTime: PreviewImageTime

    enum CodingKeys: String, CodingKey {
        case displayTarget = "display_target"
        case position
        case previewImageTime = "preview_image_time"
    }
}

private struct PreviewImageTime: Codable, Equatable, DynamicNodeEncoding {
    @XMLAttributeNode var format: String
    var value: String

    enum CodingKeys: String, CodingKey {
        case format
        case value = ""
    }

    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        switch key {
        case CodingKeys.format:
            return .attribute
        default:
            return .element
        }
    }
}

final class AttributedIntrinsicTest: XCTestCase {
    func testEncode() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = []

        let foo1 = FooEmptyKeyed(id: .init("123"), unkeyedValue: 456)

        let header = XMLHeader(version: 1.0, encoding: "UTF-8")
        let encoded = try encoder.encode(foo1, withRootKey: "foo", header: header)
        let xmlString = String(data: encoded, encoding: .utf8)
        XCTAssertNotNil(xmlString)

        // Test string equivalency
        let encodedXML = xmlString!.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalXML = String(data: fooXML, encoding: .utf8)!.trimmingCharacters(in: .whitespacesAndNewlines)
        XCTAssertEqual(encodedXML, originalXML)
    }

    func testDecode() throws {
        let decoder = XMLDecoder()
        decoder.errorContextLength = 10

        let foo1 = try decoder.decode(Foo.self, from: fooXML)
        XCTAssertEqual(foo1.id, "123")
        XCTAssertEqual(foo1.value, "456")

        let foo2 = try decoder.decode(FooEmptyKeyed.self, from: fooXML)
        XCTAssertEqual(foo2.id, "123")
        XCTAssertEqual(foo2.unkeyedValue, 456)
    }

    func testDecodePreview() throws {
        let decoder = XMLDecoder()

        let preview = try decoder.decode(AppPreview.self, from: previewXML)
        XCTAssertEqual(AppPreview(
            displayTarget: "iOS-6.5-in",
            position: 1,
            previewImageTime: PreviewImageTime(
                format: .init("24/999 1000/nonDrop"),
                value: "00:00:17:01"
            )
        ), preview)
    }

    func testFooArray() throws {
        let decoder = XMLDecoder()

        let foo1 = try decoder.decode(Container<Foo>.self, from: fooArrayXML)
        XCTAssertEqual(foo1, Container(foo: [
            Foo(id: "123", value: "456"),
            Foo(id: "789", value: "123"),
        ]))

        let foo2 = try decoder.decode(
            Container<FooEmptyKeyed>.self,
            from: fooArrayXML
        )
        XCTAssertEqual(foo2, Container(foo: [
            FooEmptyKeyed(id: .init("123"), unkeyedValue: 456),
            FooEmptyKeyed(id: .init("789"), unkeyedValue: 123),
        ]))
    }

    func testIntArray() throws {
        let decoder = XMLDecoder()

        let foo = try decoder.decode(Container<Int>.self, from: fooArrayXML)
        XCTAssertEqual(foo, Container(foo: [456, 123]))
    }

    func testMixedArray() throws {
        let decoder = XMLDecoder()

        let foo = try decoder.decode(Container<Int>.self, from: fooMixedXML)
        XCTAssertEqual(foo, Container(foo: [456, 123, 789]))
    }

    func testFooValueArray() throws {
        let decoder = XMLDecoder()

        let foo = try decoder.decode(Container<FooValue>.self, from: fooValueXML)
        XCTAssertEqual(foo, Container(foo: [
            FooValue(value: 456),
            FooValue(value: 123),
            FooValue(value: 789),
        ]))
    }

    func testFooOptionalArray() throws {
        let decoder = XMLDecoder()

        let foo = try decoder.decode(
            Container<FooOptional>.self,
            from: fooValueXML
        )
        XCTAssertEqual(foo, Container(foo: [
            FooOptional(id: nil, value: 456),
            FooOptional(id: nil, value: 123),
            FooOptional(id: nil, value: 789),
        ]))
    }

    func testFooValueAttribute() throws {
        let foo = try XMLDecoder().decode(
            FooValueAttribute.self,
            from: fooValueAttributeXML
        )
        XCTAssertEqual(foo.valueAttribute, "blah")
        XCTAssertEqual(foo.value, 456)
    }

    func testFooValueElement() throws {
        let foo = try XMLDecoder().decode(
            FooValueElement.self,
            from: fooValueElementXML
        )
        XCTAssertEqual(foo.valueElement, "blah")
        XCTAssertNil(foo.value)
    }
}
