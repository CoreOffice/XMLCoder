//
//  UnkeyedBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/18/18.
//

import XCTest
@testable import XMLCoder

class UnkeyedBoxTests: XCTestCase {
    lazy var box = UnkeyedBox([StringBox("foo"), IntBox(42)])
    
    func testUnbox() {
        let unboxed = box.unbox()
        XCTAssertEqual(unboxed.count, 2)
        XCTAssertEqual(unboxed[0] as? StringBox, StringBox("foo"))
        XCTAssertEqual(unboxed[1] as? IntBox, IntBox(42))
    }
    
    func testXMLString() {
        XCTAssertEqual(box.xmlString(), nil)
    }
}
