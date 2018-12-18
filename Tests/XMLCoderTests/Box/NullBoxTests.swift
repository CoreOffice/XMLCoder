//
//  NullBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class NullBoxTests: XCTestCase {
    func testXMLString() {
        let box = NullBox()
        XCTAssertEqual(box.xmlString, "")
    }
}
