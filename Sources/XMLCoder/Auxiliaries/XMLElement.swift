//
//  XMLElement.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/18/18.
//

import Foundation

class _XMLElement {
    static let attributesKey = "___ATTRIBUTES"
    static let escapedCharacterSet = [("&", "&amp"), ("<", "&lt;"), (">", "&gt;"), ("'", "&apos;"), ("\"", "&quot;")]
    
    var key: String
    var value: String?
    var attributes: [String: String] = [:]
    var elements: [String: [_XMLElement]] = [:]
    
    init(key: String, value: String? = nil, attributes: [String: String] = [:], elements: [String: [_XMLElement]] = [:]) {
        self.key = key
        self.value = value
        self.attributes = attributes
        self.elements = elements
    }
    
    static func createRootElement(rootKey: String, object: UnkeyedBox) -> _XMLElement? {
        let element = _XMLElement(key: rootKey)
        
        _XMLElement.createElement(parentElement: element, key: rootKey, object: object)
        
        return element
    }
    
    static func createRootElement(rootKey: String, object: KeyedBox) -> _XMLElement? {
        let element = _XMLElement(key: rootKey)
        
        _XMLElement.modifyElement(element: element, parentElement: nil, key: nil, object: object)
        
        return element
    }
    
    fileprivate static func modifyElement(element: _XMLElement, parentElement: _XMLElement?, key: String?, object: KeyedBox) {
        let uniqueAttributes: [(String, String)]? = object.attributes.compactMap { key, box in
            return box.xmlString().map { (key, $0) }
        }
        element.attributes = uniqueAttributes.map { Dictionary(uniqueKeysWithValues: $0) } ?? [:]
        
        for (key, box) in object.elements {
            _XMLElement.createElement(parentElement: element, key: key, object: box)
        }
        
        if let parentElement = parentElement, let key = key {
            parentElement.elements[key] = (parentElement.elements[key] ?? []) + [element]
        }
    }
    
    fileprivate static func createElement(parentElement: _XMLElement, key: String, object: Box) {
        switch object {
        case let box as UnkeyedBox:
            for box in box.unbox() {
                _XMLElement.createElement(parentElement: parentElement, key: key, object: box)
            }
        case let box as KeyedBox:
            modifyElement(element: _XMLElement(key: key), parentElement: parentElement, key: key, object: box)
        case _:
            let element = _XMLElement(key: key, value: object.xmlString())
            parentElement.elements[key, default: []].append(element)
        }
    }
    
    func append(value string: String) {
        var value = self.value ?? ""
        value += string.trimmingCharacters(in: .whitespacesAndNewlines)
        self.value = value
    }
    
    func flatten() -> KeyedBox {
        let attributes = self.attributes.mapValues { StringBox($0) }
        var elements: [String: Box] = [:]
        
        for element in self.elements {
            for child in element.value {
                if let content = child.value {
                    if let oldContent = elements[element.key] as? UnkeyedBox {
                        oldContent.append(StringBox(content))
                        // FIXME: Box is a reference type, so this shouldn't be necessary:
                        elements[element.key] = oldContent
                    } else if let oldContent = elements[element.key] {
                        elements[element.key] = UnkeyedBox([oldContent, StringBox(content)])
                    } else {
                        elements[element.key] = StringBox(content)
                    }
                } else if !child.elements.isEmpty || !child.attributes.isEmpty {
                    let newValue = child.flatten()
                    
                    if let existingValue = elements[element.key] {
                        if let unkeyed = existingValue as? UnkeyedBox {
                            unkeyed.append(newValue)
                            // FIXME: Box is a reference type, so this shouldn't be necessary:
                            elements[element.key] = unkeyed
                        } else {
                            elements[element.key] = UnkeyedBox([existingValue, newValue])
                        }
                    } else {
                        elements[element.key] = newValue
                    }
                }
            }
        }
        
        return KeyedBox(elements: elements, attributes: attributes)
    }
    
    func toXMLString(with header: XMLHeader? = nil, withCDATA cdata: Bool, formatting: XMLEncoder.OutputFormatting, ignoreEscaping _: Bool = false) -> String {
        if let header = header, let headerXML = header.toXML() {
            return headerXML + _toXMLString(withCDATA: cdata, formatting: formatting)
        }
        return _toXMLString(withCDATA: cdata, formatting: formatting)
    }
    
    fileprivate func formatUnsortedXMLElements(_ string: inout String, _ level: Int, _ cdata: Bool, _ formatting: XMLEncoder.OutputFormatting, _ prettyPrinted: Bool) {
        formatXMLElements(from: elements.map { (key: $0, value: $1) }, into: &string, at: level, cdata: cdata, formatting: formatting, prettyPrinted: prettyPrinted)
    }
    
    fileprivate func elementString(for element: (key: String, value: [_XMLElement]), at level: Int, cdata: Bool, formatting: XMLEncoder.OutputFormatting, prettyPrinted: Bool) -> String {
        var string = ""
        for child in element.value {
            string += child._toXMLString(indented: level + 1, withCDATA: cdata, formatting: formatting)
            string += prettyPrinted ? "\n" : ""
        }
        return string
    }
    
    fileprivate func formatSortedXMLElements(_ string: inout String, _ level: Int, _ cdata: Bool, _ formatting: XMLEncoder.OutputFormatting, _ prettyPrinted: Bool) {
        formatXMLElements(from: elements.sorted { $0.key < $1.key }, into: &string, at: level, cdata: cdata, formatting: formatting, prettyPrinted: prettyPrinted)
    }
    
    fileprivate func attributeString(key: String, value: String) -> String {
        return " \(key)=\"\(value.escape(_XMLElement.escapedCharacterSet))\""
    }
    
    fileprivate func formatXMLAttributes(from keyValuePairs: [(key: String, value: String)], into string: inout String) {
        for (key, value) in keyValuePairs {
            string += attributeString(key: key, value: value)
        }
    }
    
    fileprivate func formatXMLElements(from elements: [(key: String, value: [_XMLElement])], into string: inout String, at level: Int, cdata: Bool, formatting: XMLEncoder.OutputFormatting, prettyPrinted: Bool) {
        for element in elements {
            string += elementString(for: element, at: level, cdata: cdata, formatting: formatting, prettyPrinted: prettyPrinted)
        }
    }
    
    fileprivate func formatSortedXMLAttributes(_ string: inout String) {
        formatXMLAttributes(from: attributes.sorted(by: { $0.key < $1.key }), into: &string)
    }
    
    fileprivate func formatUnsortedXMLAttributes(_ string: inout String) {
        formatXMLAttributes(from: attributes.map { (key: $0, value: $1) }, into: &string)
    }
    
    fileprivate func formatXMLAttributes(_ formatting: XMLEncoder.OutputFormatting, _ string: inout String) {
        if #available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) {
            if formatting.contains(.sortedKeys) {
                formatSortedXMLAttributes(&string)
                return
            }
            formatUnsortedXMLAttributes(&string)
            return
        }
        formatUnsortedXMLAttributes(&string)
    }
    
    fileprivate func formatXMLElements(_ formatting: XMLEncoder.OutputFormatting, _ string: inout String, _ level: Int, _ cdata: Bool, _ prettyPrinted: Bool) {
        if #available(macOS 10.13, iOS 11.0, watchOS 4.0, tvOS 11.0, *) {
            if formatting.contains(.sortedKeys) {
                formatSortedXMLElements(&string, level, cdata, formatting, prettyPrinted)
                return
            }
            formatUnsortedXMLElements(&string, level, cdata, formatting, prettyPrinted)
            return
        }
        formatUnsortedXMLElements(&string, level, cdata, formatting, prettyPrinted)
    }
    
    fileprivate func _toXMLString(indented level: Int = 0, withCDATA cdata: Bool, formatting: XMLEncoder.OutputFormatting, ignoreEscaping: Bool = false) -> String {
        let prettyPrinted = formatting.contains(.prettyPrinted)
        let indentation = String(repeating: " ", count: (prettyPrinted ? level : 0) * 4)
        var string = indentation
        string += "<\(key)"
        
        formatXMLAttributes(formatting, &string)
        
        if let value = value {
            string += ">"
            if !ignoreEscaping {
                string += (cdata == true ? "<![CDATA[\(value)]]>" : "\(value.escape(_XMLElement.escapedCharacterSet))")
            } else {
                string += "\(value)"
            }
            string += "</\(key)>"
        } else if !elements.isEmpty {
            string += prettyPrinted ? ">\n" : ">"
            formatXMLElements(formatting, &string, level, cdata, prettyPrinted)
            
            string += indentation
            string += "</\(key)>"
        } else {
            string += " />"
        }
        
        return string
    }
}

extension _XMLElement: Equatable {
    static func == (lhs: _XMLElement, rhs: _XMLElement) -> Bool {
        guard
            lhs.key == rhs.key,
            lhs.value == rhs.value,
            lhs.attributes == rhs.attributes,
            lhs.elements == rhs.elements
            else {
                return false
        }
        return true
    }
}
