//
//  XMLElement.swift
//  XMLCoder
//
//  Created by Vincent Esche on 12/18/18.
//

import Foundation

struct _XMLElement {
    static let attributesKey = "___ATTRIBUTES"
    static let escapedCharacterSet = [("&", "&amp;"), ("<", "&lt;"), (">", "&gt;"), ("'", "&apos;"), ("\"", "&quot;")]

    var key: String
    var value: String?
    var elements: [_XMLElement] = []
    var attributes: [String: String] = [:]

    init(key: String, value: String? = nil, elements: [_XMLElement] = [], attributes: [String: String] = [:]) {
        self.key = key
        self.value = value
        self.elements = elements
        self.attributes = attributes
    }

    init(key: String, box: UnkeyedBox) {
        let elements = box.map { box in
            _XMLElement(key: key, box: box)
        }

        self.init(key: key, elements: elements)
    }

    init(key: String, box: KeyedBox) {
        var elements: [_XMLElement] = []

        for (key, box) in box.elements {
            switch box {
            case let sharedUnkeyedBox as SharedBox<UnkeyedBox>:
                let box = sharedUnkeyedBox.unbox() as! UnkeyedBox
                elements.append(contentsOf: box.map { _XMLElement(key: key, box: $0) })
            case let unkeyedBox as UnkeyedBox:
                // This basically injects the unkeyed children directly into self:
                elements.append(contentsOf: unkeyedBox.map {
                    _XMLElement(key: key, box: $0)
                })
            case let sharedKeyedBox as SharedBox<KeyedBox>:
                let box = sharedKeyedBox.unbox() as! KeyedBox
                elements.append(_XMLElement(key: key, box: box))
            case let keyedBox as KeyedBox:
                elements.append(_XMLElement(key: key, box: keyedBox))
            case let simpleBox as SimpleBox:
                elements.append(_XMLElement(key: key, box: simpleBox))
            case let box:
                preconditionFailure("Unclassified box: \(type(of: box))")
            }
        }

        let attributes: [String: String] = Dictionary(uniqueKeysWithValues: box.attributes.compactMap { key, box in
            guard let value = box.xmlString() else {
                return nil
            }
            return (key, value)
        })

        self.init(key: key, elements: elements, attributes: attributes)
    }

    init(key: String, box: SimpleBox) {
        self.init(key: key)
        value = box.xmlString()
    }

    init(key: String, box: Box) {
        switch box {
        case let sharedUnkeyedBox as SharedBox<UnkeyedBox>:
            self.init(key: key, box: sharedUnkeyedBox.unbox())
        case let sharedKeyedBox as SharedBox<KeyedBox>:
            self.init(key: key, box: sharedKeyedBox.unbox())
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
        elements.append(element)
    }

    func flatten() -> KeyedBox {
        let attributes = self.attributes.mapValues { StringBox($0) }

        var elements: [String: Box] = [:]

        for element in self.elements {
            let key = element.key

            let hasValue = element.value != nil
            let hasElements = !element.elements.isEmpty
            let hasAttributes = !element.attributes.isEmpty

            if hasValue || hasElements || hasAttributes {
                if let content = element.value {
                    switch elements[key] {
                    case var unkeyedBox as UnkeyedBox:
                        unkeyedBox.append(StringBox(content))
                        elements[key] = unkeyedBox
                    case let stringBox as StringBox:
                        elements[key] = UnkeyedBox([stringBox, StringBox(content)])
                    default:
                        elements[key] = StringBox(content)
                    }
                }
                if hasElements || hasAttributes {
                    let content = element.flatten()
                    switch elements[key] {
                    case var unkeyedBox as UnkeyedBox:
                        unkeyedBox.append(content)
                        elements[key] = unkeyedBox
                    case let box?:
                        elements[key] = UnkeyedBox([box, content])
                    default:
                        elements[key] = content
                    }
                }
            } else {
                switch elements[key] {
                case var unkeyedBox as UnkeyedBox:
                    unkeyedBox.append(NullBox())
                    elements[key] = unkeyedBox
                case let box?:
                    elements[key] = UnkeyedBox([box, NullBox()])
                default:
                    elements[key] = NullBox()
                }
            }
        }

        let keyedBox = KeyedBox(elements: elements, attributes: attributes)

        return keyedBox
    }

    func toXMLString(with header: XMLHeader? = nil, withCDATA cdata: Bool, formatting: XMLEncoder.OutputFormatting, ignoreEscaping _: Bool = false) -> String {
        if let header = header, let headerXML = header.toXML() {
            return headerXML + _toXMLString(withCDATA: cdata, formatting: formatting)
        }
        return _toXMLString(withCDATA: cdata, formatting: formatting)
    }

    fileprivate func formatUnsortedXMLElements(_ string: inout String, _ level: Int, _ cdata: Bool, _ formatting: XMLEncoder.OutputFormatting, _ prettyPrinted: Bool) {
        formatXMLElements(from: elements, into: &string, at: level, cdata: cdata, formatting: formatting, prettyPrinted: prettyPrinted)
    }

    fileprivate func elementString(for element: _XMLElement, at level: Int, cdata: Bool, formatting: XMLEncoder.OutputFormatting, prettyPrinted: Bool) -> String {
        var string = ""
        string += element._toXMLString(indented: level + 1, withCDATA: cdata, formatting: formatting)
        string += prettyPrinted ? "\n" : ""
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

    fileprivate func formatXMLElements(from elements: [_XMLElement], into string: inout String, at level: Int, cdata: Bool, formatting: XMLEncoder.OutputFormatting, prettyPrinted: Bool) {
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
        if formatting.contains(.sortedKeys) {
            formatSortedXMLAttributes(&string)
            return
        }
        formatUnsortedXMLAttributes(&string)
    }

    fileprivate func formatXMLElements(_ formatting: XMLEncoder.OutputFormatting, _ string: inout String, _ level: Int, _ cdata: Bool, _ prettyPrinted: Bool) {
        if formatting.contains(.sortedKeys) {
            formatSortedXMLElements(&string, level, cdata, formatting, prettyPrinted)
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

extension _XMLElement: Equatable {}
