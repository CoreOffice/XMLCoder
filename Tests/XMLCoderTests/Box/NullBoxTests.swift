//
//  NullBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class NullBoxTests: XCTestCase {
    typealias Boxed = NullBox

    func testXMLString() {
        let box = Boxed()
        XCTAssertEqual(box.xmlString(), nil)
    }
}
