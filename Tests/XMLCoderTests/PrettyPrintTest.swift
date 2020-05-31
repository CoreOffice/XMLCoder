// Copyright (c) 2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import XCTest
import XMLCoder

private struct TopContainer: Encodable {
    let nested: NestedContainer
}

private struct NestedContainer: Encodable {
    let values: [String]
}

final class PrettyPrintTest: XCTestCase {
    private let testContainer = TopContainer(nested: NestedContainer(values: ["foor", "bar"]))

    func testDefaultIndentation() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]

        let encoded = try encoder.encode(testContainer)

        XCTAssertEqual(
            String(data: encoded, encoding: .utf8)!,
            """
            <TopContainer>
                <nested>
                    <values>foor</values>
                    <values>bar</values>
                </nested>
            </TopContainer>
            """
        )
    }

    func testSpaces() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.prettyPrintIndentation = .spaces(3)

        let encoded = try encoder.encode(testContainer)

        XCTAssertEqual(
            String(data: encoded, encoding: .utf8)!,
            """
            <TopContainer>
               <nested>
                  <values>foor</values>
                  <values>bar</values>
               </nested>
            </TopContainer>
            """
        )
    }

    func testTabs() throws {
        let encoder = XMLEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        encoder.prettyPrintIndentation = .tabs(2)

        let encoded = try encoder.encode(testContainer)

        XCTAssertEqual(
            String(data: encoded, encoding: .utf8)!,
            """
            <TopContainer>
            \t\t<nested>
            \t\t\t\t<values>foor</values>
            \t\t\t\t<values>bar</values>
            \t\t</nested>
            </TopContainer>
            """
        )
    }
}
