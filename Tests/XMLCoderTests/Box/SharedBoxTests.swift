//
//  SharedBoxTests.swift
//  XMLCoderTests
//
//  Created by Vincent Esche on 12/26/18.
//

import XCTest
@testable import XMLCoder

class SharedBoxTests: XCTestCase {
    func testInit() {
        let box = SharedBox(BoolBox(false))
        box.withShared { shared in
            XCTAssertFalse(shared.unbox())
        }
    }

    func testIsNull() {
        let box = SharedBox(BoolBox(false))
        XCTAssertEqual(box.isNull, false)
    }

    func testXMLString() {
        let nullBox = NullBox()
        let sharedNullBox = SharedBox(nullBox)
        XCTAssertEqual(sharedNullBox.xmlString(), nullBox.xmlString())

        let boolBox = BoolBox(false)
        let sharedBoolBox = SharedBox(boolBox)
        XCTAssertEqual(sharedBoolBox.xmlString(), boolBox.xmlString())

        let intBox = IntBox(42)
        let sharedIntBox = SharedBox(intBox)
        XCTAssertEqual(sharedIntBox.xmlString(), intBox.xmlString())

        let stringBox = StringBox("lorem ipsum")
        let sharedStringBox = SharedBox(stringBox)
        XCTAssertEqual(sharedStringBox.xmlString(), stringBox.xmlString())
    }

    func testWithShared() {
        let sharedBox = SharedBox(UnkeyedBox())
        let sharedBoxAlias = sharedBox

        XCTAssertEqual(sharedBox.withShared { $0.count }, 0)
        XCTAssertEqual(sharedBoxAlias.withShared { $0.count }, 0)

        sharedBox.withShared { unkeyedBox in
            unkeyedBox.append(NullBox())
        }

        XCTAssertEqual(sharedBox.withShared { $0.count }, 1)
        XCTAssertEqual(sharedBoxAlias.withShared { $0.count }, 1)

        sharedBoxAlias.withShared { unkeyedBox in
            unkeyedBox.append(NullBox())
        }

        XCTAssertEqual(sharedBox.withShared { $0.count }, 2)
        XCTAssertEqual(sharedBoxAlias.withShared { $0.count }, 2)
    }
}
