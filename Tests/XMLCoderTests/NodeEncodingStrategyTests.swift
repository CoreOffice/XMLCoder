import XCTest
@testable import XMLCoder

class NodeEncodingStrategyTests: XCTestCase {
    fileprivate struct SingleContainer: Encodable {
        let element: Element
        
        enum CodingKeys: String, CodingKey {
            case element = "element"
        }
    }
    
    fileprivate struct KeyedContainer: Encodable {
        let elements: [String: Element]
        
        enum CodingKeys: String, CodingKey {
            case elements = "element"
        }
    }
    
    fileprivate struct UnkeyedContainer: Encodable {
        let elements: [Element]
        
        enum CodingKeys: String, CodingKey {
            case elements = "element"
        }
    }
    
    fileprivate struct Element: Encodable {
        let key: String = "value"
        
        enum CodingKeys: CodingKey {
            case key
        }
        
        static func nodeEncoding(forKey codingKey: CodingKey) -> XMLEncoder.NodeEncoding {
            return .attribute
        }
    }
    
    func testSingleContainer() {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let container = SingleContainer(element: Element())
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!
            
            let expected =
"""
<container>
    <element>
        <key>value</key>
    </element>
</container>
"""
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
        
        encoder.nodeEncodingStrategy = .custom { codableType, encoder in
            guard let barType = codableType as? Element.Type else {
                return { _ in return .default }
            }
            return barType.nodeEncoding(forKey:)
        }
        
        do {
            let container = SingleContainer(element: Element())
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!
            
            let expected =
"""
<container>
    <element key=\"value\" />
</container>
"""
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
    }
    
    func testKeyedContainer() {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let container = KeyedContainer(elements: ["first": Element()])
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!
            
            let expected =
            """
<container>
    <element>
        <first>
            <key>value</key>
        </first>
    </element>
</container>
"""
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
        
        encoder.nodeEncodingStrategy = .custom { codableType, encoder in
            guard let barType = codableType as? Element.Type else {
                return { _ in return .default }
            }
            return barType.nodeEncoding(forKey:)
        }
        
        do {
            let container = KeyedContainer(elements: ["first": Element()])
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!
            
            let expected =
            """
<container>
    <element>
        <first key=\"value\" />
    </element>
</container>
"""
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
    }
    
    func testUnkeyedContainer() {
        let encoder = XMLEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let container = UnkeyedContainer(elements: [Element(), Element()])
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!
            
            let expected =
"""
<container>
    <element>
        <key>value</key>
    </element>
    <element>
        <key>value</key>
    </element>
</container>
"""
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
        
        encoder.nodeEncodingStrategy = .custom { codableType, encoder in
            guard let barType = codableType as? Element.Type else {
                return { _ in return .default }
            }
            return barType.nodeEncoding(forKey:)
        }
        
        do {
            let container = UnkeyedContainer(elements: [Element(), Element()])
            let data = try encoder.encode(container, withRootKey: "container")
            let xml = String(data: data, encoding: .utf8)!
            
            let expected =
"""
<container>
    <element key="value" />
    <element key="value" />
</container>
"""
            XCTAssertEqual(xml, expected)
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
    }
    
    static var allTests = [
        ("testSingleContainer", testSingleContainer),
        ("testKeyedContainer", testKeyedContainer),
        ("testUnkeyedContainer", testUnkeyedContainer),
    ]
}
