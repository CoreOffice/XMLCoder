//
//  DateBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/19/18.
//

import XCTest
@testable import XMLCoder

class DateBoxTests: XCTestCase {
    typealias Boxed = DateBox

    let customFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    func testIsNull() {
        let box = Boxed(Date(), format: .iso8601)
        XCTAssertEqual(box.isNull, false)
    }

    func testUnbox() {
        let values: [Boxed.Unboxed] = [
            Date(timeIntervalSince1970: 0.0),
            Date(timeIntervalSinceReferenceDate: 0.0),
            Date(),
        ]

        for unboxed in values {
            let box = Boxed(unboxed, format: .iso8601)
            XCTAssertEqual(box.unbox(), unboxed)
        }
    }

    func testValidStrings_secondsSince1970() {
        let xmlStrings = [
            "-1000.0",
            "0.0",
            "1000.0",
        ]

        for xmlString in xmlStrings {
            let boxOrNil = Boxed(secondsSince1970: xmlString)
            XCTAssertNotNil(boxOrNil)

            guard let box = boxOrNil else { continue }

            XCTAssertEqual(box.xmlString(), xmlString)
        }
    }

    func testValidStrings_millisecondsSince1970() {
        let xmlStrings = [
            "-1000.0",
            "0.0",
            "1000.0",
        ]

        for xmlString in xmlStrings {
            let boxOrNil = Boxed(millisecondsSince1970: xmlString)
            XCTAssertNotNil(boxOrNil)

            guard let box = boxOrNil else { continue }

            XCTAssertEqual(box.xmlString(), xmlString)
        }
    }

    func testValidStrings_iso8601() {
        let xmlStrings = [
            "1970-01-23T01:23:45Z",
        ]

        for xmlString in xmlStrings {
            let boxOrNil = Boxed(iso8601: xmlString)
            XCTAssertNotNil(boxOrNil)

            guard let box = boxOrNil else { continue }

            XCTAssertEqual(box.xmlString(), xmlString)
        }
    }

    func testValidStrings_formatter() {
        let xmlStrings = [
            "1970-01-23 01:23:45",
        ]

        for xmlString in xmlStrings {
            let boxOrNil = Boxed(xmlString: xmlString, formatter: customFormatter)
            XCTAssertNotNil(boxOrNil)

            guard let box = boxOrNil else { continue }

            XCTAssertEqual(box.xmlString(), xmlString)
        }
    }

    func testInvalidStrings_secondsSince1970() {
        let xmlStrings = [
            "lorem ipsum",
            "",
        ]

        for xmlString in xmlStrings {
            let boxOrNil = Boxed(secondsSince1970: xmlString)
            XCTAssertNil(boxOrNil)
        }
    }

    func testInvalidStrings_millisecondsSince1970() {
        let xmlStrings = [
            "lorem ipsum",
            "",
        ]

        for xmlString in xmlStrings {
            let boxOrNil = Boxed(millisecondsSince1970: xmlString)
            XCTAssertNil(boxOrNil)
        }
    }

    func testInvalidStrings_iso8601() {
        let xmlStrings = [
            "lorem ipsum",
            "",
        ]

        for xmlString in xmlStrings {
            let boxOrNil = Boxed(iso8601: xmlString)
            XCTAssertNil(boxOrNil)
        }
    }

    func testInvalidStrings_formatter() {
        let xmlStrings = [
            "lorem ipsum",
            "",
        ]

        for xmlString in xmlStrings {
            let boxOrNil = Boxed(xmlString: xmlString, formatter: customFormatter)
            XCTAssertNil(boxOrNil)
        }
    }
}
