import XCTest
@testable import XMLCoder

let example = """
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
    <Relationship
        Id="rId1"
        Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
        Target="xl/workbook.xml"/>
    <Relationship
        Id="rId2"
        Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties"
        Target="docProps/app.xml"/>
    <Relationship
        Id="rId3"
        Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties"
        Target="docProps/core.xml"/>
</Relationships>
"""

struct Relationships: Codable {
    let items: [Relationship]

    enum CodingKeys: String, CodingKey {
        case items = "relationship"
    }
}

struct Relationship: Codable {
    enum SchemaType: String, Codable {
        case officeDocument = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"
        case extendedProperties = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties"
        case coreProperties = "http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties"
    }

    let id: String
    let type: SchemaType
    let target: String

    enum CodingKeys: CodingKey {
        case type
        case id
        case target
    }
}

class XMLCoderTests: XCTestCase {
    func testExample() {
        do {
            guard let data = example.data(using: .utf8) else { return }

            let decoder = XMLDecoder()
            decoder.keyDecodingStrategy = .convertFromCapitalized

            let rels = try decoder.decode(Relationships.self, from: data)

            XCTAssertEqual(rels.items[0].id, "rId1")
        } catch {
            XCTAssert(false, "failed to decode the example: \(error)")
        }
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
