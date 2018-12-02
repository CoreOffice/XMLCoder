import Foundation
import XCTest
import XMLCoder

class CharacterDataDecodingTestCase: DecodingTestCase {
    override func setUp() {
        super.setUp()
        decoder.characterDataToken = "#text"
    }
    
    func testItDecodesCharData() {
        // given
        struct Attribute: Decodable, Equatable {
            enum CodingKeys: String, CodingKey {
                case name
                case value = "#text"
            }
            
            let name: String
            let value: String
        }
        let xml = """
        <attribute name="Xpos">0</attribute>
        """
        
        // when
        let attr: Attribute = try! decode(xml)
        
        // then
        XCTAssertEqual(attr, Attribute(name: "Xpos", value: "0"))
    }
}
