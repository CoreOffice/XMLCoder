// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class UnkeyedBoxTests: XCTestCase {
    let box: UnkeyedBox = [StringBox("foo"), IntBox(42)]

    func testIsNull() {
        let box = UnkeyedBox()
        XCTAssertEqual(box.isNull, false)
    }

    func testUnbox() {
        XCTAssertEqual(box.count, 2)
        XCTAssertEqual(box[0] as? StringBox, StringBox("foo"))
        XCTAssertEqual(box[1] as? IntBox, IntBox(42))
    }

    func testXMLString() {
        XCTAssertEqual(box.xmlString, nil)
    }

    func testDescription() {
        XCTAssertEqual(box.description, "[foo, 42]")
    }

    func testSequence() {
        let sequence = IteratorSequence(box.makeIterator())
        let array: [Box] = Array(sequence)
        XCTAssertEqual(array[0] as? StringBox, StringBox("foo"))
        XCTAssertEqual(array[1] as? IntBox, IntBox(42))
    }

    func testSubscript() {
        var box = self.box
        box[0] = NullBox()
        XCTAssertEqual(box.count, 2)
        XCTAssertEqual(box[0] as? NullBox, NullBox())
        XCTAssertEqual(box[1] as? IntBox, IntBox(42))
    }

    func testInsertAt() {
        var box = self.box
        box.insert(NullBox(), at: 1)
        XCTAssertEqual(box.count, 3)

        XCTAssertEqual(box[0] as? StringBox, StringBox("foo"))
        XCTAssertEqual(box[1] as? NullBox, NullBox())
        XCTAssertEqual(box[2] as? IntBox, IntBox(42))
    }
}
