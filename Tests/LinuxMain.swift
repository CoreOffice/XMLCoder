import XCTest
@testable import XMLCoderTests

XCTMain([
    testCase(RelationshipsTest.allTests),
    testCase(BreakfastTest.allTests),
    testCase(NodeEncodingStrategyTests.allTests),
    testCase(BooksTest.allTests),
    testCase(NoteTest.allTests),
    testCase(PlantTest.allTests),
])
