//
//  EmptyElementEmptyStringTests.swift
//  XMLCoderTests
//
//  Created by James Bean on 9/29/19.
//

import XCTest
import XMLCoder

class EmptyElementEmptyStringTests: XCTestCase {

    struct ContainerMultiple: Equatable, Decodable {
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

    struct ContainerSingle: Equatable, Codable {
        let thing: Thing
    }

    struct Thing: Equatable, Codable {
        let attribute: String?
        let value: String
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

    func testNestedEmptyElementEmptyStringDecoding() throws {
        let xml = """
        <container>
            <thing/>
        </container>
        """
        let expected = ContainerSingle(thing: Thing(attribute: nil, value: ""))
        let result = try XMLDecoder().decode(ContainerSingle.self, from: xml.data(using: .utf8)!)
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
        let expected = ContainerMultiple(
            things: [
                Thing(attribute: nil, value: ""),
                Thing(attribute: "x", value: ""),
                Thing(attribute: nil, value: ""),
            ]
        )
        let result = try XMLDecoder().decode(ContainerMultiple.self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(expected, result)
    }
}
