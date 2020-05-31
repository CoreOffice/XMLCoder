// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Max Desiatov on 12/05/2019.
//

import XCTest
@testable import XMLCoder

private let xml = """
<borders count="1">
<border/>
</borders>
""".data(using: .utf8)!

struct Borders: Codable, Equatable {
    let items: [Border?]
    let count: Int

    enum CodingKeys: String, CodingKey {
        case items = "border"
        case count
    }
}

struct LeftBorders: Codable, Equatable {
    let items: [LeftBorder?]
    let count: Int

    enum CodingKeys: String, CodingKey {
        case items = "border"
        case count
    }
}

struct Border: Codable, Equatable {
    struct Value: Codable, Equatable {
        let style: String?
    }

    let left: Value?
    let right: Value?
    let top: Value?
    let bottom: Value?
    let diagonal: Value?
    let horizontal: Value?
    let vertical: Value?

    init() {
        left = nil
        right = nil
        top = nil
        bottom = nil
        diagonal = nil
        horizontal = nil
        vertical = nil
    }
}

struct LeftBorder: Codable, Equatable {
    struct Value: Codable, Equatable {
        let style: String?
    }

    var left: Value
    var right: Value?
    var top: Value?
    var bottom: Value?
    var diagonal: Value?
    var horizontal: Value?
    var vertical: Value?
}

final class BorderTest: XCTestCase {
    func testSingleEmpty() throws {
        let result = try XMLDecoder().decode(Borders.self, from: xml)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.items[0], Border())
    }

    func testLeftBorder() throws {
        let result = try XMLDecoder().decode(LeftBorders.self, from: xml)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.items[0], nil)
    }
}
