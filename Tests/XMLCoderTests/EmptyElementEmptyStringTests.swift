// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by James Bean on 9/29/19.
//

import XCTest
import XMLCoder

final class EmptyElementEmptyStringTests: XCTestCase {
    struct ExplicitNestingContainer: Equatable, Decodable {
        let things: ContainedArray

        struct ContainedArray: Equatable, Decodable {
            let thing: [Thing]

            init(_ things: [Thing]) {
                thing = things
            }
        }
    }

    struct NestingContainer: Equatable, Decodable {
        let things: [Thing]

        enum CodingKeys: String, CodingKey {
            case things
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            var things = [Thing]()
            if var thingContainer = try? container.nestedUnkeyedContainer(forKey: .things) {
                while !thingContainer.isAtEnd {
                    things.append(try thingContainer.decode(Thing.self))
                }
            }
            self.things = things
        }

        init(things: [Thing]) {
            self.things = things
        }
    }

    struct Parent: Equatable, Codable {
        let thing: Thing
    }

    struct Thing: Equatable, Codable {
        let attribute: String?
        let value: String

        enum CodingKeys: String, CodingKey {
            case attribute
            case value = ""
        }
    }

    func testEmptyElementEmptyStringDecoding() throws {
        let xml = """
        <thing></thing>
        """
        let expected = Thing(attribute: nil, value: "")
        let result = try XMLDecoder().decode(Thing.self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }

    func testEmptyElementEmptyStringWithAttributeDecoding() throws {
        let xml = """
        <thing attribute="x"></thing>
        """
        let expected = Thing(attribute: "x", value: "")
        let result = try XMLDecoder().decode(Thing.self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }

    func testArrayOfEmptyElementStringDecoding() throws {
        let xml = """
        <container>
            <thing></thing>
            <thing attribute="x"></thing>
            <thing></thing>
        </container>
        """
        let expected = [
            Thing(attribute: nil, value: ""),
            Thing(attribute: "x", value: ""),
            Thing(attribute: nil, value: ""),
        ]
        let result = try XMLDecoder().decode([Thing].self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }

    func testArrayOfSomeEmptyElementStringDecoding() throws {
        let xml = """
        <container>
            <thing></thing>
            <thing attribute="x">Non-Empty!</thing>
            <thing>Non-Empty!</thing>
        </container>
        """
        let expected = [
            Thing(attribute: nil, value: ""),
            Thing(attribute: "x", value: "Non-Empty!"),
            Thing(attribute: nil, value: "Non-Empty!"),
        ]
        let result = try XMLDecoder().decode([Thing].self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }

    func testNestedEmptyElementEmptyStringDecoding() throws {
        let xml = """
        <parent>
            <thing/>
        </parent>
        """
        let expected = Parent(thing: Thing(attribute: nil, value: ""))
        let result = try XMLDecoder().decode(Parent.self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }

    func testExplicitlyNestedArrayOfEmptyElementEmptyStringDecoding() throws {
        let xml = """
        <container>
            <things>
                <thing></thing>
                <thing attribute="x"></thing>
                <thing></thing>
            </things>
        </container>
        """
        let expected = ExplicitNestingContainer(
            things: .init([
                Thing(attribute: nil, value: ""),
                Thing(attribute: "x", value: ""),
                Thing(attribute: nil, value: ""),
            ])
        )
        let result = try XMLDecoder().decode(ExplicitNestingContainer.self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }

    func testExplicitlyNestedArrayOfSomeEmptyElementEmptyStringDecoding() throws {
        let xml = """
        <container>
            <things>
                <thing></thing>
                <thing attribute="x">Non-Empty!</thing>
                <thing>Non-Empty!</thing>
            </things>
        </container>
        """
        let expected = ExplicitNestingContainer(
            things: .init([
                Thing(attribute: nil, value: ""),
                Thing(attribute: "x", value: "Non-Empty!"),
                Thing(attribute: nil, value: "Non-Empty!"),
            ])
        )
        let result = try XMLDecoder().decode(ExplicitNestingContainer.self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }

    func testNestedArrayOfEmptyElementEmptyStringDecoding() throws {
        let xml = """
        <container>
            <things>
                <thing></thing>
                <thing attribute="x"></thing>
                <thing></thing>
            </things>
        </container>
        """
        let expected = NestingContainer(
            things: [
                Thing(attribute: nil, value: ""),
                Thing(attribute: "x", value: ""),
                Thing(attribute: nil, value: ""),
            ]
        )
        let result = try XMLDecoder().decode(NestingContainer.self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }

    func testNestedArrayOfSomeEmptyElementEmptyStringDecoding() throws {
        let xml = """
        <container>
            <things>
                <thing></thing>
                <thing attribute="x">Non-Empty!</thing>
                <thing>Non-Empty!</thing>
            </things>
        </container>
        """
        let expected = NestingContainer(
            things: [
                Thing(attribute: nil, value: ""),
                Thing(attribute: "x", value: "Non-Empty!"),
                Thing(attribute: nil, value: "Non-Empty!"),
            ]
        )
        let result = try XMLDecoder().decode(NestingContainer.self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }
}
