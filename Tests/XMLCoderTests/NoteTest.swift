//
//  NoteTest.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 19/11/2018.
//

import Foundation
import XCTest
@testable import XMLCoder

private let validXml = """
<?xml version="1.0" encoding="UTF-8"?>
<note>
    <to>Tove</to>
    <from>Jani</from>
    <heading>Reminder</heading>
    <body>Don't forget me this weekend!</body>
</note>
""".data(using: .utf8)!

private let invalidXml = """
<?xml version="1.0" encoding="UTF-8"?>
<note>
  <to>Tove</to>
  <from>Jani</Ffrom>
  <heading>Reminder</heading>
  <body>Don't forget me this weekend!</body>
</note>
""".data(using: .utf8)!

private struct Note: Codable, Equatable {
    var to: String
    var from: String
    var heading: String
    var body: String
}

final class NoteTest: XCTestCase {
    func testValidXML() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        let note1 = try decoder.decode(Note.self, from: validXml)
        XCTAssertEqual(note1.to, "Tove")
        XCTAssertEqual(note1.from, "Jani")
        XCTAssertEqual(note1.heading, "Reminder")
        XCTAssertEqual(note1.body, "Don't forget me this weekend!")

        let data = try encoder.encode(note1, withRootKey: "note",
                                      header: XMLHeader(version: 1.0,
                                                        encoding: "UTF-8"))
        let note2 = try decoder.decode(Note.self, from: data)
        XCTAssertEqual(note1, note2)
    }

    func testInvalidXML() {
        let decoder = XMLDecoder()

        XCTAssertThrowsError(try decoder.decode(Note.self, from: invalidXml))
    }

    static var allTests = [
        ("testValidXML", testValidXML),
        ("testInvalidXML", testInvalidXML),
    ]
}
