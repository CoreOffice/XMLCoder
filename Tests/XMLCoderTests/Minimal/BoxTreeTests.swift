// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Max Desiatov on 07/04/2019.
//

import XCTest
@testable import XMLCoder

class BoxTreeTests: XCTestCase {
    func testNestedValues() throws {
        let e1 = XMLCoderElement(
            key: "foo",
            stringValue: "456",
            attributes: [Attribute(key: "id", value: "123")]
        )
        let e2 = XMLCoderElement(
            key: "foo",
            stringValue: "123",
            attributes: [Attribute(key: "id", value: "789")]
        )
        let root = XMLCoderElement(
            key: "container",
            elements: [e1, e2],
            attributes: []
        )

        let boxTree = root.transformToBoxTree() as? KeyedBox
        let foo = boxTree?.elements["foo"]
        XCTAssertEqual(foo?.count, 2)
    }
}
