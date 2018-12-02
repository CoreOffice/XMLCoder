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

	func testItDecodesCharDataWhenNested() {
		// given
		struct Item: Decodable, Equatable {
			enum CodingKeys: String, CodingKey {
				case id = "ID"
				case creator = "Creator"
				case children = "attribute"
			}

			let id: String
			let creator: String
			let children: [Attribute]?
		}

		struct Attribute: Decodable, Equatable {
			enum CodingKeys: String, CodingKey {
				case name
				case value = "#text"
			}

			let name: String
			let value: String?
		}

		let xml = """
			<item ID="1542637462" Creator="Francisco Moya">
			<attribute name="Xpos">0</attribute>
			</item>
			"""

		// when
		let result: Item = try! decode(xml)

		// then
		let expected = Item(id: "1542637462", creator: "Francisco Moya", children: nil)
		XCTAssertEqual(result, expected)
	}
}
