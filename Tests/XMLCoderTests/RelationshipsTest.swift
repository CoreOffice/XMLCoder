import XCTest
@testable import XMLCoder

private let xml = """
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
""".data(using: .utf8)!

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

class RelationshipsTest: XCTestCase {
    func testDecoder() {
        do {
            let decoder = XMLDecoder()
            decoder.keyDecodingStrategy = .convertFromCapitalized

            let rels = try decoder.decode(Relationships.self, from: xml)

            XCTAssertEqual(rels.items[0].id, "rId1")
        } catch {
            XCTAssert(false, "failed to decode test xml: \(error)")
        }
    }

    static var allTests = [
        ("testDecoder", testDecoder),
    ]
}
