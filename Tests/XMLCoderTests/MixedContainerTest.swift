//
//  MixedContainerTest.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 21/05/2019.
//

import XCTest
@testable import XMLCoder

private struct Container<T: Codable>: Codable {
    let unkeyed: [T]
    let keyed: [String: T]
}

private let xml = """
<container>
    <unkeyed>
        <unkeyed>1</unkeyed>
        <unkeyed>2</unkeyed>
        <unkeyed>3</unkeyed>
        <unkeyed>4</unkeyed>
        <unkeyed>5</unkeyed>
    </unkeyed>
    <unkeyed>
        <unkeyed>1</unkeyed>
        <unkeyed>2</unkeyed>
        <unkeyed>3</unkeyed>
        <unkeyed>4</unkeyed>
        <unkeyed>5</unkeyed>
    </unkeyed>
    <keyed>
        <key_213>1</key_213>
        <key_213>2</key_213>
        <key_213>3</key_213>
        <key_213>4</key_213>
        <key_213>5</key_213>
        <key_364>1</key_364>
        <key_364>2</key_364>
        <key_364>3</key_364>
        <key_364>4</key_364>
        <key_364>5</key_364>
        <key_489>1</key_489>
        <key_489>2</key_489>
        <key_489>3</key_489>
        <key_489>4</key_489>
        <key_489>5</key_489>
    </keyed>
</container>
""".data(using: .utf8)!

final class MixedContainerTest: XCTestCase {
    func test() throws {
        let result = try XMLDecoder().decode(Container<[Int]>.self, from: xml)
        XCTAssertEqual(result.unkeyed.count, 2)
    }
}
