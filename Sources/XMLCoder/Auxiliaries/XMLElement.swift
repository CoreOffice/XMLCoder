//
//  XMLElement.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/18/18.
//

import Foundation

struct _XMLElement {
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

    init(key: String, box: UnkeyedBox) {
        self.init(key: key)

        elements[key] = box.map { box in
            _XMLElement(key: key, box: box)
        }
    }

    init(key: String, box: KeyedBox) {
        self.init(key: key)

        attributes = Dictionary(uniqueKeysWithValues: box.attributes.compactMap { key, box in
            guard let value = box.xmlString() else {
                return nil
            }
            return (key, value)
        })

        let elementsByKey: [(String, [_XMLElement])] = box.elements.map { key, box in
            switch box {
            case let unkeyedBox as UnkeyedBox:
                // This basically injects the unkeyed children directly into self:
                let elements = unkeyedBox.map { _XMLElement(key: key, box: $0) }
                return (key, elements)
            case let keyedBox as KeyedBox:
                let elements = [_XMLElement(key: key, box: keyedBox)]
                return (key, elements)
            case let simpleBox as SimpleBox:
                let elements = [_XMLElement(key: key, box: simpleBox)]
                return (key, elements)
            case let box:
                preconditionFailure("Unclassified box: \(type(of: box))")
            }
        }

        elements = Dictionary(elementsByKey) { existingElements, newElements in
            existingElements + newElements
        }
    }

    init(key: String, box: SimpleBox) {
        self.init(key: key)
        value = box.xmlString()
    }

    init(key: String, box: Box) {
        switch box {
        case let unkeyedBox as UnkeyedBox:
            self.init(key: key, box: unkeyedBox)
        case let keyedBox as KeyedBox:
            self.init(key: key, box: keyedBox)
        case let simpleBox as SimpleBox:
            self.init(key: key, box: simpleBox)
        case let box:
            preconditionFailure("Unclassified box: \(type(of: box))")
        }
    }

    mutating func append(value string: String) {
        var value = self.value ?? ""
        value += string.trimmingCharacters(in: .whitespacesAndNewlines)
        self.value = value
    }

    mutating func append(element: _XMLElement, forKey key: String) {
        elements[key, default: []].append(element)
    }

    func flatten() -> KeyedBox {
        let attributes = self.attributes.mapValues { StringBox($0) }

        var elements: [String: Box] = [:]
        for (key, value) in self.elements {
            for child in value {
                if let content = child.value {
                    switch elements[key] {
                    case let unkeyedBox as UnkeyedBox:
                        var boxes = unkeyedBox.unbox()
                        boxes.append(StringBox(content))
                        elements[key] = UnkeyedBox(boxes)
                    case let keyedBox as StringBox:
                        elements[key] = UnkeyedBox([keyedBox, StringBox(content)])
                    case _:
                        elements[key] = StringBox(content)
                    }
                } else if !child.elements.isEmpty || !child.attributes.isEmpty {
                    let content = child.flatten()
                    if let existingValue = elements[key] {
                        if let unkeyedBox = existingValue as? UnkeyedBox {
                            var boxes = unkeyedBox.unbox()
                            boxes.append(content)
                            elements[key] = UnkeyedBox(boxes)
                        } else {
                            elements[key] = UnkeyedBox([existingValue, content])
                        }
                    } else {
                        elements[key] = content
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
