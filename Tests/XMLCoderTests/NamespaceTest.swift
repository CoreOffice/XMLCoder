//
//  NamespaceTest.swift
//  XMLCoder
//
//  Created by Max Desiatov on 27/02/2019.
//

import Foundation
import XCTest
@testable import XMLCoder

private let tableXML = """
<h:table xmlns:h="http://www.w3.org/TR/html4/">
  <h:tr>
    <h:td>Apples</h:td>
    <h:td>Bananas</h:td>
  </h:tr>
</h:table>
""".data(using: .utf8)!

private struct Table: Codable, Equatable {
    struct TR: Codable, Equatable {
        let td: [String]
    }

    let tr: [TR]
}

private struct NamespacedTable: Codable, Equatable {
    struct TR: Codable, Equatable {
        enum CodingKeys: String, CodingKey {
            case td = "h:td"
        }

        let td: [String]
    }

    enum CodingKeys: String, CodingKey {
        case tr = "h:tr"
    }

    let tr: [TR]
}

private let worksheetXML = """
<?xml version="1.0" encoding="utf-8"?>
<x:worksheet \
xmlns:x="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <x:sheetData>
    <x:row r="1">
      <x:c t="str" r="A1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="B1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="C1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="D1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="E1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="F1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="G1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="H1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="I1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="J1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="K1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="L1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="M1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="N1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="O1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="P1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="Q1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="R1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="S1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="T1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="U1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="V1">
        <x:v>Scolumn name</x:v>
      </x:c>
      <x:c t="str" r="W1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="X1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="Y1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="Z1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="AA1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="AB1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="AC1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="AD1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="AE1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="AF1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="AG1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="AH1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="AI1">
        <x:v>column name</x:v>
      </x:c>
      <x:c t="str" r="AJ1">
        <x:v>column name</x:v>
      </x:c>
    </x:row>
    <x:row r="2">
    </x:row>
  </x:sheetData>
</x:worksheet>
""".data(using: .utf8)!

private struct Cell: Codable, Equatable {
    let type: String?
    let s: String?
    let formula: String?
    let value: String?

    enum CodingKeys: String, CodingKey {
        case formula = "f"
        case value = "v"
        case type = "t"
        case s
    }
}

private struct Worksheet: Codable {
    struct Data: Codable {
        public let rows: [Row]

        enum CodingKeys: String, CodingKey {
            case rows = "row"
        }
    }

    let data: Data?

    enum CodingKeys: String, CodingKey {
        case data = "sheetData"
    }
}

private struct Row: Codable {
    let reference: UInt
    let height: Double?
    let customHeight: String?
    let cells: [Cell]

    enum CodingKeys: String, CodingKey {
        case cells = "c"
        case reference = "r"
        case height = "ht"
        case customHeight
    }
}

private struct NamespacedCell: Codable, Equatable {
    let type: String?
    let s: String?
    let formula: String?
    let value: String?

    enum CodingKeys: String, CodingKey {
        case formula = "f"
        case value = "v"
        case type = "t"
        case s
    }
}

private struct NamespacedWorksheet: Codable {
    struct Data: Codable {
        public let rows: [NamespacedRow]

        enum CodingKeys: String, CodingKey {
            case rows = "x:row"
        }
    }

    let data: Data?

    enum CodingKeys: String, CodingKey {
        case data = "x:sheetData"
    }
}

private struct NamespacedRow: Codable {
    let reference: UInt
    let height: Double?
    let customHeight: String?
    let cells: [NamespacedCell]

    enum CodingKeys: String, CodingKey {
        case cells = "x:c"
        case reference = "r"
        case height = "ht"
        case customHeight
    }
}

final class NamespaceTest: XCTestCase {
    func testTable() throws {
        let decoder = XMLDecoder()
        decoder.shouldProcessNamespaces = true

        var decoded = try decoder.decode(Table.self, from: tableXML)
        XCTAssertEqual(decoded, Table(tr: [.init(td: ["Apples", "Bananas"])]))

        decoder.shouldProcessNamespaces = false
        decoded = try decoder.decode(Table.self, from: tableXML)
        XCTAssertEqual(decoded, Table(tr: []))
    }

    func testWorksheet() throws {
        let decoder = XMLDecoder()
        decoder.shouldProcessNamespaces = true

        var worksheet = try decoder.decode(Worksheet.self, from: worksheetXML)
        XCTAssertEqual(worksheet.data?.rows[0].cells.count, 36)

        decoder.shouldProcessNamespaces = false
        worksheet = try decoder.decode(Worksheet.self, from: worksheetXML)
        XCTAssertNil(worksheet.data)
    }

    func testTableWithoutNamespaces() throws {
        let decoder = XMLDecoder()
        decoder.shouldProcessNamespaces = false

        var decoded = try decoder.decode(NamespacedTable.self, from: tableXML)
        XCTAssertEqual(decoded, NamespacedTable(tr: [.init(td: ["Apples", "Bananas"])]))

        decoder.shouldProcessNamespaces = true
        decoded = try decoder.decode(NamespacedTable.self, from: tableXML)
        XCTAssertEqual(decoded, NamespacedTable(tr: []))
    }

    func testWorksheetWithoutNamespaces() throws {
        let decoder = XMLDecoder()
        decoder.shouldProcessNamespaces = false

        var worksheet = try decoder.decode(NamespacedWorksheet.self, from: worksheetXML)
        XCTAssertEqual(worksheet.data?.rows[0].cells.count, 36)

        decoder.shouldProcessNamespaces = true
        worksheet = try decoder.decode(NamespacedWorksheet.self, from: worksheetXML)
        XCTAssertNil(worksheet.data)
    }
}
