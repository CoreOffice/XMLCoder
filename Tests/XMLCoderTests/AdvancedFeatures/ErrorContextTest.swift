// Copyright (c) 2018-2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT
//
//  Created by Matvii Hodovaniuk on 12/27/18.
//

import Foundation
import XCTest
@testable import XMLCoder

final class ErrorContextTest: XCTestCase {
    struct Container: Codable {
        let value: [String: Int]
    }

    func testErrorContextFirstLine() {
        let decoder = XMLDecoder()
        decoder.errorContextLength = 8

        let xmlString = "<blah //>"
        let xmlData = xmlString.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Container.self,
                                                from: xmlData)) { error in
            guard case let DecodingError.dataCorrupted(ctx) = error,
                  let underlying = ctx.underlyingError
            else {
                XCTAssert(false, "wrong error type thrown")
                return
            }

            #if os(Linux)
            // XML Parser returns a different column on Linux
            // https://bugs.swift.org/browse/SR-11192
            XCTAssertEqual(ctx.debugDescription, """
            \(underlying.localizedDescription) \
            at line 1, column 7:
            `ah //>`
            """)
            #else
            XCTAssertEqual(ctx.debugDescription, """
            \(underlying.localizedDescription) \
            at line 1, column 2:
            `<blah `
            """)
            #endif
        }
    }

    func testErrorContext() {
        let decoder = XMLDecoder()
        decoder.errorContextLength = 8

        let xmlString =
            """
            <container>
                test1
            </blah>
            <container>
                test2
            </container>
            """
        let xmlData = xmlString.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Container.self,
                                                from: xmlData)) { error in
            guard case let DecodingError.dataCorrupted(ctx) = error,
                  let underlying = ctx.underlyingError
            else {
                XCTAssert(false, "wrong error type thrown")
                return
            }

            #if os(Linux)
            // XML Parser returns a different column on Linux
            // https://bugs.swift.org/browse/SR-11192
            XCTAssertEqual(ctx.debugDescription, """
            \(underlying.localizedDescription) \
            at line 4, column 1:
            `blah>
            <c`
            """)
            #else
            XCTAssertEqual(ctx.debugDescription, """
            \(underlying.localizedDescription) \
            at line 3, column 8:
            `blah>
            <c`
            """)
            #endif
        }
    }

    func testErrorContextSizeOutsizeContent() {
        let decoder = XMLDecoder()
        decoder.errorContextLength = 10

        let xmlString =
            """
            container>
                test1
            </blah>
            <container>
                test2
            </container>
            """
        let xmlData = xmlString.data(using: .utf8)!

        XCTAssertThrowsError(try decoder.decode(Container.self,
                                                from: xmlData)) { error in
            guard case let DecodingError.dataCorrupted(ctx) = error,
                  let underlying = ctx.underlyingError
            else {
                XCTAssert(false, "wrong error type thrown")
                return
            }

            XCTAssertEqual(ctx.debugDescription, """
            \(underlying.localizedDescription) \
            at line 1, column 1:
            `contai`
            """)
        }
    }
}
