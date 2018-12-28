//
//  ErrorHandle.swift
//  XMLCoder
//
//  Created by Matvii Hodovaniuk on 12/27/18.
//

import Foundation
import XCTest
@testable import XMLCoder

final class ErrorHandleTest: XCTestCase {
    struct Container: Codable, Equatable {
        let value: [String: Int]
    }
    
    func testErroHandle() {
        let decoder = XMLDecoder()
        decoder.errorContextLength = 10
        
        do {
            let xmlString = """
                <?xml version="1.0" encoding="UTF-8"?>
                <container>
                <<</container>
            """
            let xmlData = xmlString.data(using: .utf8)!
            
            XCTAssertThrowsError(try decoder.decode(Container.self, from: xmlData))(decoded.value, [:])
        } catch {
            XCTAssert(false, "failed to decode test xml: \(error)")
        }
    }
    static var allTests = [
        ("testErroHandle", testErroHandle),
    ]
}

