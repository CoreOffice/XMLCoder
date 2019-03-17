//
//  BreakfastTest.swift
//  XMLCoderTests
//
//  Created by Max Desiatov on 19/11/2018.
//

import Foundation
import XCTest
@testable import XMLCoder

private let xml = """
<?xml version="1.0" encoding="UTF-8"?>
<breakfast_menu>
  <food>
    <name>Belgian Waffles</name>
    <price>$5.95</price>
    <description>Two of our famous Belgian Waffles with plenty of real maple syrup</description>
    <calories></calories>
  </food>
  <food>
    <name>Strawberry Belgian Waffles</name>
    <price>$7.95</price>
    <description>Light Belgian waffles covered with strawberries and whipped cream</description>
    <calories>900</calories>
  </food>
  <food>
    <name>Berry-Berry Belgian Waffles</name>
    <price>$8.95</price>
    <description>Light Belgian waffles covered with an assortment of fresh berries and whipped cream</description>
    <calories>900</calories>
  </food>
  <food>
    <name>French Toast</name>
    <price>$4.50</price>
    <description>Thick slices made from our homemade sourdough bread</description>
    <calories>600</calories>
  </food>
  <food>
    <name>Homestyle Breakfast</name>
    <price>$6.95</price>
    <description>Two eggs, bacon or sausage, toast, and our ever-popular hash browns</description>
    <calories>950</calories>
  </food>
</breakfast_menu>
""".data(using: .utf8)!

private struct Menu: Codable, Equatable {
    var food: [Food]
}

private struct Food: Codable, Equatable {
    var name: String
    var price: String
    var description: String
    var calories: Int?
}

final class BreakfastTest: XCTestCase {
    func testXML() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        let menu1 = try decoder.decode(Menu.self, from: xml)
        XCTAssertEqual(menu1.food.count, 5)

        let data = try encoder.encode(menu1, withRootKey: "breakfast_menu",
                                      header: XMLHeader(version: 1.0,
                                                        encoding: "UTF-8"))
        let menu2 = try decoder.decode(Menu.self, from: data)
        XCTAssertEqual(menu1, menu2)
    }

    static var allTests = [
        ("testXML", testXML),
    ]
}
