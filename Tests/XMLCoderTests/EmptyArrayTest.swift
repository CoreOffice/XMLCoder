// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Benjamin Wetherfield on 10/1/19.
//

import XCTest
@testable import XMLCoder

struct Empty: Equatable, Codable {}

struct EmptyArray: Equatable, Codable {
    enum CodingKeys: String, CodingKey { case empties = "empty" }
    let empties: [Empty]
}

struct EmptyWrapper: Equatable, Codable {
    let empty: Empty
}

struct OptionalEmptyWrapper: Equatable, Codable {
    let empty: Empty?
}

private let xml = """
<container>
    <empty/>
    <empty/>
    <empty/>
</container>
"""

private let xmlArray = """
<container>
    <empty/>
    <empty/>
    <empty/>
</container>
"""

private let xmlContainsEmpty = """
<container>
    <empty/>
</container>
"""

final class EmptyArrayTest: XCTestCase {
    func testEmptyArrayDecode() throws {
        let decoded = try XMLDecoder().decode([Empty].self, from: xml.data(using: .utf8)!)
        XCTAssertEqual(decoded, [Empty(), Empty(), Empty()])
    }

    func testWrappedEmptyArrayDecode() throws {
        let decoded = try XMLDecoder().decode(EmptyArray.self, from: xmlArray.data(using: .utf8)!)
        XCTAssertEqual(decoded, EmptyArray(empties: [Empty(), Empty(), Empty()]))
    }

    func testWrappedEmptyDecode() throws {
        let decoded = try XMLDecoder().decode(EmptyWrapper.self, from: xmlContainsEmpty.data(using: .utf8)!)
        XCTAssertEqual(decoded, EmptyWrapper(empty: Empty()))
    }

    func testWrappedOptionalEmptyDecode() throws {
        let decoded = try XMLDecoder().decode(OptionalEmptyWrapper.self, from: xmlContainsEmpty.data(using: .utf8)!)
        XCTAssertEqual(decoded, OptionalEmptyWrapper(empty: Empty()))
    }
}
