// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class NullBoxTests: XCTestCase {
    typealias Boxed = NullBox

    let box = Boxed()

    func testIsNull() {
        XCTAssertEqual(box.isNull, true)
    }

    func testXMLString() {
        XCTAssertEqual(box.xmlString, nil)
    }

    func testEqual() {
        XCTAssertEqual(box, Boxed())
    }

    func testDescription() {
        XCTAssertEqual(box.description, "null")
    }
}
