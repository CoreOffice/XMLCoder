//
//  OrderedDictionaryTests.swift
//  XMLCoderTests
//
//  Created by James Bean on 12/22/18.
//

import XCTest
@testable import XMLCoder

class OrderedDictionaryTests: XCTestCase {

    func testInitKeysAndUnordered() {
        let dict = OrderedDictionary(
            keys: ["zero", "one", "two"],
            unordered: ["one": 1, "two": 2, "zero": 0]
        )
        let expected: OrderedDictionary = ["zero": 0, "one": 1, "two": 2]
        XCTAssertEqual(dict, expected)
    }

    func testInitUnordered() {
        let unordered = ["one": 1, "two": 2, "zero": 0]
        let dict = OrderedDictionary(unordered)
        XCTAssertEqual(Set(unordered.keys), Set(dict.keys))
        XCTAssertEqual(Set(unordered.values), Set(dict.values))
    }

    func testInitUniqueKeysWithValues() {
        let dict = OrderedDictionary(uniqueKeysWithValues: [("zero",0), ("one",1), ("two",2)])
        let expected: OrderedDictionary = ["zero": 0, "one": 1, "two": 2]
        XCTAssertEqual(dict, expected)
    }

    func testInitKeysAndValuesUniquingKeysWith() {
        let dict = OrderedDictionary(
            [("zero", 42), ("zero", 0), ("one",1),("two",2)],
            uniquingKeysWith: { a,b in b }
        )
        let expected: OrderedDictionary = ["zero": 0, "one": 1, "two": 2]
        XCTAssertEqual(dict, expected)
    }

    func testSubscriptKeyNil() {
        let dict: OrderedDictionary<String,Int> = [:]
        XCTAssertNil(dict["zero"])
    }

    func testSubscriptInt() {
        var dict = OrderedDictionary<String,String>()
        dict.insert("val", key: "key", index: 0)
        XCTAssertEqual(dict[0].value, "val")
    }

    func testSubscriptKeyValid() {
        var dict = OrderedDictionary<String,String>()
        dict.insert("val", key: "key", index: 0)
        XCTAssertEqual(dict["key"]!, "val")
    }

    func testInsert() {
        var dict = OrderedDictionary<String, String>()
        dict.insert("val", key: "key", index: 0)
        dict.insert("insertedVal", key: "insertedKey", index: 0)
        XCTAssertEqual(dict[0].value, "insertedVal")
        XCTAssertEqual(dict[1].value, "val")
    }

    func testAppend() {
        var dict = OrderedDictionary<String, String>()
        dict.append("val", key: "key")
        dict.append("anotherVal", key: "anotherKey")
        XCTAssertEqual(dict[0].value, "val")
        XCTAssertEqual(dict[1].value, "anotherVal")
    }

    func testIterationOrdered() {
        var dict = OrderedDictionary<Int, String>()
        dict[1] = "one"
        dict[2] = "two"
        dict[3] = "three"
        dict[4] = "four"
        dict[5] = "five"
        XCTAssertEqual(dict.map { $0.0 }, [1, 2, 3, 4, 5])
        XCTAssertEqual(dict.map { $0.1 }, ["one", "two", "three", "four", "five"])
    }

    func testEquatable() {
        let a: OrderedDictionary = [1: "one", 2: "two", 3: "three"]
        let b: OrderedDictionary = [1: "one", 2: "two", 3: "three"]
        XCTAssertEqual(a,b)
    }

}
