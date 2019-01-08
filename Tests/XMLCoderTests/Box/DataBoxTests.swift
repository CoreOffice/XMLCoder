//
//  DataBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/19/18.
//

import XCTest
@testable import XMLCoder

class DataBoxTests: XCTestCase {
    typealias Boxed = DataBox

    func testIsNull() {
        let box = Boxed(Data(), format: .base64)
        XCTAssertEqual(box.isNull, false)
    }

    func testUnbox() {
        let values: [Boxed.Unboxed] = [
            Data(base64Encoded: "bG9yZW0gaXBzdW0=")!,
            Data(),
        ]

        for unboxed in values {
            let box = Boxed(unboxed, format: .base64)
            XCTAssertEqual(box.unbox(), unboxed)
        }
    }

    func testValidXMLStrings_base64() {
        let xmlStrings = [
            "",
            "bG9yZW0gaXBzdW0=",
            "ZG9sb3Igc2l0IGFtZXQ=",
            "Y29uc2VjdGV0dXIgYWRpcGlzY2luZyBlbGl0",
        ]

        for xmlString in xmlStrings {
            let boxOrNil = DataBox(base64: xmlString)
            XCTAssertNotNil(boxOrNil)

            guard let box = boxOrNil else { continue }

            XCTAssertEqual(box.xmlString(), xmlString)
        }
    }

    func testInvalidXMLStrings_base64() {
        let xmlStrings = [
            "lorem ipsum",
        ]

        for xmlString in xmlStrings {
            let box = Boxed(base64: xmlString)
            XCTAssertNil(box)
        }
    }
}
