//
//  XMLStackParser.swift
//  XMLCoder
//
//  Created by Shawn Moore on 11/14/17.
//  Copyright © 2017 Shawn Moore. All rights reserved.
//

import Foundation

//===----------------------------------------------------------------------===//
// Data Representation
//===----------------------------------------------------------------------===//

public struct XMLHeader {
    /// the XML standard that the produced document conforms to.
    public let version: Double?
    /// the encoding standard used to represent the characters in the produced document.
    public let encoding: String?
    /// indicates whether a document relies on information from an external source.
    public let standalone: String?
    
    public init(version: Double? = nil, encoding: String? = nil, standalone: String? = nil) {
        self.version = version
        self.encoding = encoding
        self.standalone = standalone
    }
    
    internal func isEmpty() -> Bool {
        return version == nil && encoding == nil && standalone == nil
    }
    
    internal func toXML() -> String? {
        guard !isEmpty() else { return nil }
        
        var string = "<?xml "
        
        if let version = version {
            string += "version=\"\(version)\" "
        }
        
        if let encoding = encoding {
            string += "encoding=\"\(encoding)\" "
        }
        
        if let standalone = standalone {
            string += "standalone=\"\(standalone)\""
        }
        
        return string.trimmingCharacters(in: .whitespaces) + "?>\n"
    }
}

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
    
    convenience init(key: String, value: Optional<CustomStringConvertible>, attributes: [String: CustomStringConvertible] = [:]) {
        self.init(key: key, value: value?.description, attributes: attributes.mapValues({ $0.description }), children: [:])
    }
    
    convenience init(key: String, children: [String: [_XMLElement]], attributes: [String: CustomStringConvertible] = [:]) {
        self.init(key: key, value: nil, attributes: attributes.mapValues({ $0.description }), children: children)
    }
    
    static func createRootElement(rootKey: String, object: NSObject) -> _XMLElement? {
        let element = _XMLElement(key: rootKey)
        
        if let object = object as? NSDictionary {
            _XMLElement.modifyElement(element: element, parentElement: nil, key: nil, object: object)
        } else if let object = object as? NSArray {
            _XMLElement.createElement(parentElement: element, key: rootKey, object: object)
        }
        
        return element
    }
    
    fileprivate static func createElement(parentElement: _XMLElement?, key: String, object: NSDictionary) {
        let element = _XMLElement(key: key)
        
        modifyElement(element: element, parentElement: parentElement, key: key, object: object)
    }
    
    fileprivate static func modifyElement(element: _XMLElement, parentElement: _XMLElement?, key: String?, object: NSDictionary) {
        element.attributes = (object[_XMLElement.attributesKey] as? [String: Any])?.mapValues({ String(describing: $0) }) ?? [:]
        
        let objects: [(String, NSObject)] = object.compactMap({
            guard let key = $0 as? String, let value = $1 as? NSObject, key != _XMLElement.attributesKey else { return nil }
            
            return (key, value)
        })
        
        for (key, value) in objects {
            if let dict = value as? NSDictionary {
                _XMLElement.createElement(parentElement: element, key: key, object: dict)
            } else if let array = value as? NSArray {
                _XMLElement.createElement(parentElement: element, key: key, object: array)
            } else if let string = value as? NSString {
                _XMLElement.createElement(parentElement: element, key: key, object: string)
            } else if let number = value as? NSNumber {
                _XMLElement.createElement(parentElement: element, key: key, object: number)
            } else {
                _XMLElement.createElement(parentElement: element, key: key, object: NSNull())
            }
        }
        
        if let parentElement = parentElement, let key = key {
            parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
        }
    }
    
    fileprivate static func createElement(parentElement: _XMLElement, key: String, object: NSArray) {
        let objects = object.compactMap({ $0 as? NSObject })
        objects.forEach({
            if let dict = $0 as? NSDictionary {
                _XMLElement.createElement(parentElement: parentElement, key: key, object: dict)
            } else if let array = $0 as? NSArray {
                _XMLElement.createElement(parentElement: parentElement, key: key, object: array)
            } else if let string = $0 as? NSString {
                _XMLElement.createElement(parentElement: parentElement, key: key, object: string)
            } else if let number = $0 as? NSNumber {
                _XMLElement.createElement(parentElement: parentElement, key: key, object: number)
            } else {
                _XMLElement.createElement(parentElement: parentElement, key: key, object: NSNull())
            }
        })
    }
    
    fileprivate static func createElement(parentElement: _XMLElement, key: String, object: NSNumber) {
        let element = _XMLElement(key: key, value: object.description)
        parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
    }
    
    fileprivate static func createElement(parentElement: _XMLElement, key: String, object: NSString) {
        let element = _XMLElement(key: key, value: object.description)
        parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
    }
    
    fileprivate static func createElement(parentElement: _XMLElement, key: String, object: NSNull) {
        let element = _XMLElement(key: key)
        parentElement.children[key] = (parentElement.children[key] ?? []) + [element]
    }
    
    fileprivate func flatten() -> [String: Any] {
        var node: [String: Any] = attributes
        
        for childElement in children {
            for child in childElement.value {
                if let content = child.value {
                    if let oldContent = node[childElement.key] as? Array<Any> {
                        node[childElement.key] = oldContent + [content]
                        
                    } else if let oldContent = node[childElement.key] {
                        node[childElement.key] = [oldContent, content]
                        
                    } else {
                        node[childElement.key] = content
                    }
                } else if !child.children.isEmpty || !child.attributes.isEmpty {
                    let newValue = child.flatten()
                    
                    if let existingValue = node[childElement.key] {
                        if var array = existingValue as? Array<Any> {
                            array.append(newValue)
                            node[childElement.key] = array
                        } else {
                            node[childElement.key] = [existingValue, newValue]
                        }
                    } else {
                        node[childElement.key] = newValue
                    }
                }
            }
        }
        
        return node
    }
    
    func toXMLString(with header: XMLHeader? = nil, withCDATA cdata: Bool, formatting: XMLEncoder.OutputFormatting, ignoreEscaping: Bool = false) -> String {
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

extension String {
    internal func escape(_ characterSet: [(character: String, escapedCharacter: String)]) -> String {
        var string = self
        
        for set in characterSet {
            string = string.replacingOccurrences(of: set.character, with: set.escapedCharacter, options: .literal)
        }
        
        return string
    }
}

internal class _XMLStackParser: NSObject, XMLParserDelegate {
    var root: _XMLElement?
    var stack = [_XMLElement]()
    var currentNode: _XMLElement?
    
    var currentElementName: String?
    var currentElementData = ""
    
    static func parse(with data: Data) throws -> [String: Any] {
        let parser = _XMLStackParser()
        
        do {
            if let node = try parser.parse(with: data) {
                return node.flatten()
            } else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "The given data could not be parsed into XML."))
            }
        } catch {
            throw error
        }
    }
    
    func parse(with data: Data) throws -> _XMLElement? {
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = self
        
        if xmlParser.parse() {
            return root
        } else if let error = xmlParser.parserError {
            throw error
        } else {
            return nil
        }
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        root = nil
        stack = [_XMLElement]()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        let node = _XMLElement(key: elementName)
        node.attributes = attributeDict
        stack.append(node)
        
        if let currentNode = currentNode {
            if currentNode.children[elementName] != nil {
                currentNode.children[elementName]?.append(node)
            } else {
                currentNode.children[elementName] = [node]
            }
        }
        currentNode = node
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let poppedNode = stack.popLast() {
            if let content = poppedNode.value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) {
                if content.isEmpty {
                    poppedNode.value = nil
                } else {
                    poppedNode.value = content
                }
            }
            
            if stack.isEmpty {
                root = poppedNode
                currentNode = nil
            } else {
                currentNode = stack.last
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentNode?.value = (currentNode?.value ?? "") + string
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if let string = String(data: CDATABlock, encoding: .utf8) {
            currentNode?.value = (currentNode?.value ?? "") + string
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError)
    }
}
