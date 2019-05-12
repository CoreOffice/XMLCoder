//
//  BorderTest.swift
//  XMLCoderTests
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
    let items: [Border]
    let count: Int

    enum CodingKeys: String, CodingKey {
        case items = "border"
        case count
    }
}

public struct Border: Codable, Equatable {
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

final class BorderTest: XCTestCase {
    func testSingleEmpty() throws {
        let result = try XMLDecoder().decode(Borders.self, from: xml)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.items[0], Border())
    }
}
