//
//  XMLElement.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/18/18.
//

import Foundation

internal class _XMLElement {
    static let attributesKey = "___ATTRIBUTES"
    static let escapedCharacterSet = [("&", "&amp"), ("<", "&lt;"), (">", "&gt;"), ("'", "&apos;"), ("\"", "&quot;")]
    
    var key: String
    var value: String?
    var attributes: [String: String] = [:]
    var children: [String: [_XMLElement]] = [:]
    
    internal init(key: String, value: String? = nil, attributes: [String: String] = [:], children: [String: [_XMLElement]] = [:]) {
        self.key = key
        self.value = value
        self.attributes = attributes
        self.children = children
    }
    
    static func createRootElement(rootKey: String, object: UnkeyedBox) -> _XMLElement? {
        let element = _XMLElement(key: rootKey)
        
        _XMLElement.createElement(parentElement: element, key: rootKey, object: object)
        
        return element
    }
    
    static func createRootElement(rootKey: String, object: DictionaryBox) -> _XMLElement? {
        let element = _XMLElement(key: rootKey)
        
        _XMLElement.modifyElement(element: element, parentElement: nil, key: nil, object: object)
        
        return element
    }
    
    fileprivate static func modifyElement(element: _XMLElement, parentElement: _XMLElement?, key: String?, object: DictionaryBox) {
        let attributesBox = object[_XMLElement.attributesKey] as? DictionaryBox
        let uniqueAttributes: [(String, String)]? = attributesBox?.unbox().compactMap { key, box in
            return box.xmlString().map { (key, $0) }
        }
        element.attributes = uniqueAttributes.map { Dictionary(uniqueKeysWithValues: $0) } ?? [:]
        
        let objects = object.filter { key, _value in key != _XMLElement.attributesKey }
        
        for (key, box) in objects {
            _XMLElement.createElement(parentElement: element, key: key, object: box)
        }
        
        if let parentElement = parentElement, let key = key {
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        }
    }
    
    fileprivate static func createElement(parentElement: _XMLElement, key: String, object: Box) {
        switch object {
        case let box as UnkeyedBox:
            for box in box.unbox() {
                _XMLElement.createElement(parentElement: parentElement, key: key, object: box)
            }
        case let box as DictionaryBox:
            modifyElement(element: _XMLElement(key: key), parentElement: parentElement, key: key, object: box)
        case _:
            let element = _XMLElement(key: key, value: object.xmlString())
            parentElement.children[key, default: []].append(element)
        }
        
    }
    
    func append(value string: String) {
        var value = self.value ?? ""
        value += string.trimmingCharacters(in: .whitespacesAndNewlines)
        self.value = value
    }
    
    internal func flatten() -> [String: Box] {
        var node: [String: Box] = attributes.mapValues { StringBox($0) }
        
        for childElement in children {
            for child in childElement.value {
                if let content = child.value {
                    if let oldContent = node[childElement.key] as? UnkeyedBox {
                        oldContent.append(StringBox(content))
                        // FIXME: Box is a reference type, so this shouldn't be necessary:
                        node[childElement.key] = oldContent
                    } else if let oldContent = node[childElement.key] {
                        node[childElement.key] = UnkeyedBox([oldContent, StringBox(content)])
                    } else {
                        node[childElement.key] = StringBox(content)
                    }
                } else if !child.children.isEmpty || !child.attributes.isEmpty {
                    let newValue = child.flatten()
                    
                    if let existingValue = node[childElement.key] {
                        if let unkeyed = existingValue as? UnkeyedBox {
                            unkeyed.append(DictionaryBox(newValue))
                            // FIXME: Box is a reference type, so this shouldn't be necessary:
                            node[childElement.key] = unkeyed
                        } else {
                            node[childElement.key] = UnkeyedBox([existingValue, DictionaryBox(newValue)])
                        }
                    } else {
                        node[childElement.key] = DictionaryBox(newValue)
                    }
                }
            }
        }
        
        return node
    }
    
    func toXMLString(with header: XMLHeader? = nil, withCDATA cdata: Bool, formatting: XMLEncoder.OutputFormatting, ignoreEscaping _: Bool = false) -> String {
        if let header = header, let headerXML = header.toXML() {
            return headerXML + _toXMLString(withCDATA: cdata, formatting: formatting)
        }
        return _toXMLString(withCDATA: cdata, formatting: formatting)
    }
    
    fileprivate func formatUnsortedXMLElements(_ string: inout String, _ level: Int, _ cdata: Bool, _ formatting: XMLEncoder.OutputFormatting, _ prettyPrinted: Bool) {
        formatXMLElements(from: children.map { (key: $0, value: $1) }, into: &string, at: level, cdata: cdata, formatting: formatting, prettyPrinted: prettyPrinted)
    }
    
    fileprivate func elementString(for childElement: (key: String, value: [_XMLElement]), at level: Int, cdata: Bool, formatting: XMLEncoder.OutputFormatting, prettyPrinted: Bool) -> String {
        var string = ""
        for child in childElement.value {
            string += child._toXMLString(indented: level + 1, withCDATA: cdata, formatting: formatting)
            string += prettyPrinted ? "\n" : ""
        }
        return string
    }
    
    fileprivate func formatSortedXMLElements(_ string: inout String, _ level: Int, _ cdata: Bool, _ formatting: XMLEncoder.OutputFormatting, _ prettyPrinted: Bool) {
        formatXMLElements(from: children.sorted { $0.key < $1.key }, into: &string, at: level, cdata: cdata, formatting: formatting, prettyPrinted: prettyPrinted)
    }
    
    fileprivate func attributeString(key: String, value: String) -> String {
        return " \(key)=\"\(value.escape(_XMLElement.escapedCharacterSet))\""
    }
    
    fileprivate func formatXMLAttributes(from keyValuePairs: [(key: String, value: String)], into string: inout String) {
        for (key, value) in keyValuePairs {
            string += attributeString(key: key, value: value)
        }
    }
    
    fileprivate func formatXMLElements(from children: [(key: String, value: [_XMLElement])], into string: inout String, at level: Int, cdata: Bool, formatting: XMLEncoder.OutputFormatting, prettyPrinted: Bool) {
        for childElement in children {
            string += elementString(for: childElement, at: level, cdata: cdata, formatting: formatting, prettyPrinted: prettyPrinted)
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
        } else if !children.isEmpty {
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
            lhs.children == rhs.children
        else {
            return false
        }
        return true
    }
}
