//
//  String+ExtensionsTests.swift
//  XMLCoderTests
//
//  Created by Joseph Mattiello on 1/31/19.
//

import XCTest
@testable import XMLCoder

class StringExtensionsTests: XCTestCase {
    func testCapitalizingFirstLetter() {
        let testStrings = ["lower", "UPPER", "snake_cased", "RaNdOm", ""]
        let expected = ["Lower", "UPPER", "Snake_cased", "RaNdOm", ""]
        let converted = testStrings.map { $0.capitalizingFirstLetter() }

        XCTAssertEqual(expected, converted)

        // Mutable version
        let mutated: [String] = testStrings.map { s in
            var s = s
            s.capitalizeFirstLetter()
            return s
        }
        XCTAssertEqual(expected, mutated)
    }

    func testLowercasingFirstLetter() {
        let testStrings = ["lower", "UPPER", "snake_cased", "RaNdOm", ""]
        let expected = ["lower", "uPPER", "snake_cased", "raNdOm", ""]
        let converted = testStrings.map { $0.lowercasingFirstLetter() }

        XCTAssertEqual(expected, converted)

        // Mutable version
        let mutated: [String] = testStrings.map { s in
            var s = s
            s.lowercaseFirstLetter()
            return s
        }
        XCTAssertEqual(expected, mutated)
    }
}
