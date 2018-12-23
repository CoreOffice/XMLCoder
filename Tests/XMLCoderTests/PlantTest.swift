//
//  PlantTest.swift
//  XMLCoderTests
//
//  Created by Shawn Moore on 11/15/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation
import XCTest
@testable import XMLCoder

private struct PlantCatalog: Codable, Equatable {
    var plants: [Plant]

    enum CodingKeys: String, CodingKey {
        case plants = "PLANT"
    }
}

private struct CurrencyCodingError: Error {}

private struct Currency: Codable, Equatable {
    let value: Decimal

    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    init(_ value: Decimal) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        guard let value = Currency.formatter
            .number(from: string)?.decimalValue else {
            throw CurrencyCodingError()
        }

        self.init(value)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(Currency.formatter
            .string(from: value as NSNumber))
    }
}

private struct Plant: Codable, Equatable {
    var common: String
    var botanical: String
    var zone: String
    var light: String
    var price: Currency
    var amountAvailable: Int

    enum CodingKeys: String, CodingKey {
        case common = "COMMON"
        case botanical = "BOTANICAL"
        case zone = "ZONE"
        case light = "LIGHT"
        case price = "PRICE"
        case amountAvailable = "AVAILABILITY"
    }

    init(common: String,
         botanical: String,
         zone: String,
         light: String,
         price: Currency,
         amountAvailable: Int) {
        self.common = common
        self.botanical = botanical
        self.zone = zone
        self.light = light
        self.price = price
        self.amountAvailable = amountAvailable
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let common = try values.decode(String.self, forKey: .common)
        let botanical = try values.decode(String.self, forKey: .botanical)
        let zone = try values.decode(String.self, forKey: .zone)
        let light = try values.decode(String.self, forKey: .light)
        let price = try values.decode(Currency.self, forKey: .price)
        let availability = try values.decode(Int.self, forKey: .amountAvailable)

        self.init(common: common,
                  botanical: botanical,
                  zone: zone,
                  light: light,
                  price: price,
                  amountAvailable: availability)
    }
}

private let lastPlant = Plant(common: "Cardinal Flower",
                              botanical: "Lobelia cardinalis",
                              zone: "2",
                              light: "Shade",
                              price: Currency(3.02),
                              amountAvailable: 22299)

final class PlantTest: XCTestCase {
    func testXML() throws {
        let decoder = XMLDecoder()
        let encoder = XMLEncoder()

        let plantCatalog1 = try decoder.decode(PlantCatalog.self,
                                               from: plantCatalogXML)
        XCTAssertEqual(plantCatalog1.plants.count, 36)
        XCTAssertEqual(plantCatalog1.plants[35], lastPlant)

        let data = try encoder.encode(plantCatalog1, withRootKey: "CATALOG",
                                      header: XMLHeader(version: 1.0,
                                                        encoding: "UTF-8"))
        let plantCatalog2 = try decoder.decode(PlantCatalog.self, from: data)

        XCTAssertEqual(plantCatalog1, plantCatalog2)
    }

    static var allTests = [
        ("testXML", testXML),
    ]
}
