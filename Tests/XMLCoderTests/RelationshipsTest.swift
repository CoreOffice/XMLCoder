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

private struct Relationships: Codable {
    let items: [Relationship]

    enum CodingKeys: String, CodingKey {
        case items = "relationship"
    }
}

private struct Relationship: Codable {
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

final class RelationshipsTest: XCTestCase {
    func testDecoder() throws {
        let decoder = XMLDecoder()
        decoder.keyDecodingStrategy = .convertFromCapitalized

        let relationships = try decoder.decode(Relationships.self, from: xml)

        XCTAssertEqual(relationships.items.count, 3)

        guard let relationship = relationships.items.first else {
            return
        }

        XCTAssertEqual(relationship.id, "rId1")
    }

    static var allTests = [
        ("testDecoder", testDecoder),
    ]
}
