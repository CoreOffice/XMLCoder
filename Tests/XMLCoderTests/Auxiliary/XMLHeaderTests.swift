//
//  XMLHeaderTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/24/18.
//

import XCTest
@testable import XMLCoder

class XMLHeaderTests: XCTestCase {
    func testInitVersionEncodingStandalone() {
        let header = XMLHeader(version: 1.0, encoding: "UTF-8", standalone: "yes")
        XCTAssertEqual(header.version, 1.0)
        XCTAssertEqual(header.encoding, "UTF-8")
        XCTAssertEqual(header.standalone, "yes")
    }

    func testInitVersionEncoding() {
        let header = XMLHeader(version: 1.0, encoding: "UTF-8")
        XCTAssertEqual(header.version, 1.0)
        XCTAssertEqual(header.encoding, "UTF-8")
        XCTAssertNil(header.standalone)
    }

    func testInitVersion() {
        let header = XMLHeader(version: 1.0)
        XCTAssertEqual(header.version, 1.0)
        XCTAssertNil(header.encoding)
        XCTAssertNil(header.standalone)
    }

    func testInit() {
        let header = XMLHeader()
        XCTAssertNil(header.version)
        XCTAssertNil(header.encoding)
        XCTAssertNil(header.standalone)
    }

    func testIsEmpty() {
        let empty = XMLHeader()
        XCTAssertTrue(empty.isEmpty())

        let nonEmpty = XMLHeader(version: 1.0)
        XCTAssertFalse(nonEmpty.isEmpty())
    }

    func testToXML() {
        let empty = XMLHeader()
        XCTAssertNil(empty.toXML())

        let version = XMLHeader(version: 1.0)
        XCTAssertEqual(version.toXML(), "<?xml version=\"1.0\"?>\n")

        let versionEncoding = XMLHeader(version: 1.0, encoding: "UTF-8")
        XCTAssertEqual(versionEncoding.toXML(), "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")

        let versionEncodingStandalone = XMLHeader(version: 1.0, encoding: "UTF-8", standalone: "yes")
        XCTAssertEqual(versionEncodingStandalone.toXML(), "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n")
    }
}
