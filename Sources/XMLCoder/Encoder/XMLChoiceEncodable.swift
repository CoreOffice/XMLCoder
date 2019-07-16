//
//  XMLChoiceEncodable.swift
//  XMLCoder
//
//  Created by James Bean on 7/15/19.
//

public protocol XMLChoiceEncodable: Encodable {}

public protocol ArrayOfXMLChoiceEncodable {}

extension Array: ArrayOfXMLChoiceEncodable where Element: XMLChoiceEncodable {}
