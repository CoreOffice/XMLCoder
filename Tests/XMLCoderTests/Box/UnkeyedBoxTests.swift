//
//  UnkeyedBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class UnkeyedBoxTests: XCTestCase {
    typealias Boxed = UnkeyedBox

    let box = Boxed([StringBox("foo"), IntBox(42)])

    func testIsNull() {
        let box = Boxed()
        XCTAssertEqual(box.isNull, false)
    }

    func testUnbox() {
        let unboxed = box.unboxed
        XCTAssertEqual(unboxed.count, 2)
        XCTAssertEqual(unboxed[0] as? StringBox, StringBox("foo"))
        XCTAssertEqual(unboxed[1] as? IntBox, IntBox(42))
    }

    func testXMLString() {
        XCTAssertEqual(box.xmlString(), nil)
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
        var box = Boxed([StringBox("foo"), IntBox(42)])
        box[0] = KeyedBox()
        XCTAssertEqual(box.count, 2)
        let box0 = box[0] as? KeyedBox
        XCTAssertEqual(box0?.elements.isEmpty, true)
        XCTAssertEqual(box0?.attributes.isEmpty, true)
        XCTAssertEqual(box[1] as? IntBox, IntBox(42))
    }

    func testInsertAt() {
        var box = Boxed([StringBox("foo"), IntBox(42)])
        box.insert(KeyedBox(), at: 1)
        XCTAssertEqual(box.count, 3)

        let box1 = box[1] as? KeyedBox
        XCTAssertEqual(box[0] as? StringBox, StringBox("foo"))
        XCTAssertEqual(box1?.elements.isEmpty, true)
        XCTAssertEqual(box1?.attributes.isEmpty, true)
        XCTAssertEqual(box[2] as? IntBox, IntBox(42))
    }
}
