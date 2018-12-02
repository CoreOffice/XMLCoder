import Foundation
import XCTest
import XMLCoder

class DecodingTestCase: XCTestCase {
    var decoder: XMLDecoder!
    
    func decode<T>(_ string: String) throws -> T where T: Decodable {
        let data = string.data(using: .utf8)!
        let result: T = try decoder.decode(T.self, from: data)
        return result
    }
    
    override func setUp() {
        super.setUp()
        decoder = XMLDecoder()
    }
    
    override func tearDown() {
        decoder = nil
        super.tearDown()
    }
}
