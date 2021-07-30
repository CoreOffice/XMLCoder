// Copyright (c) 2019-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
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

    func testIsAllWhitespace() {
        let testString1 = ""
        let testString2 = "    "

        let testString3 = "\n"
        let testString4 = "\n        "
        let testString5 = "   \n     "
        let testString6 = "   \n"

        let testString7 = "\r"
        let testString8 = "\r        "
        let testString9 = "   \r     "
        let testString10 = "   \r"

        let testString11 = "\r\n"
        let testString12 = "\r\n    "
        let testString13 = "    \r\n    "
        let testString14 = "    \r\n"

        XCTAssert(testString1.isAllWhitespace())
        XCTAssert(testString2.isAllWhitespace())
        XCTAssert(testString3.isAllWhitespace())
        XCTAssert(testString4.isAllWhitespace())
        XCTAssert(testString5.isAllWhitespace())
        XCTAssert(testString6.isAllWhitespace())
        XCTAssert(testString7.isAllWhitespace())
        XCTAssert(testString8.isAllWhitespace())
        XCTAssert(testString9.isAllWhitespace())
        XCTAssert(testString10.isAllWhitespace())
        XCTAssert(testString11.isAllWhitespace())
        XCTAssert(testString12.isAllWhitespace())
        XCTAssert(testString13.isAllWhitespace())
        XCTAssert(testString14.isAllWhitespace())
    }
}
