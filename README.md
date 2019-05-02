# XMLCoder
Encoder &amp; Decoder for XML using Swift's `Codable` protocols.

[![CI Status](https://img.shields.io/travis/MaxDesiatov/XMLCoder/master.svg?style=flat)](https://travis-ci.org/MaxDesiatov/XMLCoder)
[![Version](https://img.shields.io/cocoapods/v/XMLCoder.svg?style=flat)](https://cocoapods.org/pods/XMLCoder)
[![License](https://img.shields.io/cocoapods/l/XMLCoder.svg?style=flat)](https://cocoapods.org/pods/XMLCoder)
[![Platform](https://img.shields.io/cocoapods/p/XMLCoder.svg?style=flat)](https://cocoapods.org/pods/XMLCoder)
[![Coverage](https://img.shields.io/codecov/c/github/MaxDesiatov/XMLCoder/master.svg?style=flat)](https://codecov.io/gh/maxdesiatov/XMLCoder)

This package is a fork of the original
[ShawnMoore/XMLParsing](https://github.com/ShawnMoore/XMLParsing)
with more features and improved test coverage.

## Example

```swift
import XMLCoder

let xmlStr = """
<note>
    <to>Bob</to>
    <from>Jane</from>
    <heading>Reminder</heading>
    <body>Don't forget to use XMLCoder!</body>
</note>
"""

struct Note: Codable {
    let to: String
    let from: String
    let heading: String
    let body: String
}

guard let data = xmlStr.data(using: .utf8) else { return }

let note = try? XMLDecoder().decode(Note.self, from: data)

let returnData = try? XMLEncoder().encode(note, withRootKey: "note")
```

## Advanced features

These features are available in [0.4.0
release](https://github.com/MaxDesiatov/XMLCoder/releases/tag/0.4.0) or later:

### Stripping namespace prefix

Sometimes you need to handle an XML namespace prefix, like in the XML below:

```xml
<h:table xmlns:h="http://www.w3.org/TR/html4/">
  <h:tr>
    <h:td>Apples</h:td>
    <h:td>Bananas</h:td>
  </h:tr>
</h:table>
```

Stripping the prefix from element names is enabled with 
`shouldProcessNamespaces` property:

```swift
struct Table: Codable, Equatable {
    struct TR: Codable, Equatable {
        let td: [String]
    }

    let tr: [TR]
}


let decoder = XMLDecoder()

// Setting this property to `true` for the namespace prefix to be stripped
// during decoding so that key names could match.
decoder.shouldProcessNamespaces = true

let decoded = try decoder.decode(Table.self, from: xmlData)
```

### Dynamic node coding

XMLCoder provides two helper protocols that allow you to customize whether nodes
are encoded and decoded as attributes or elements: `DynamicNodeEncoding` and
`DynamicNodeDecoding`.

The declarations of the protocols are very simple:

```swift
protocol DynamicNodeEncoding: Encodable {
    static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding
}

protocol DynamicNodeDecoding: Decodable {
    static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding
}
```

The values returned by corresponding `static` functions look like this:

```swift
enum NodeDecoding {
    // decodes a value from an attribute
    case attribute

    // decodes a value from an element
    case element

    // the default, attempts to decode as an element first,
    // otherwise reads from an attribute
    case elementOrAttribute 
}

enum NodeEncoding {
    // encodes a value in an attribute
    case attribute

    // the default, encodes a value in an element
    case element

    // encodes a value in both attribute and element
    case both
}
```

Add conformance to an appropriate protocol for types you'd like to customize.
Accordingly, this example code:

```swift
struct Book: Codable, Equatable, DynamicNodeEncoding {
    let id: UInt
    let title: String
    let categories: [Category]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case categories = "category"
    }

    static func nodeEncoding(forKey key: CodingKey) 
    -> XMLEncoder.NodeEncoding {
        switch key {
        case Book.CodingKeys.id: return .both
        default: return .element
        }
    }
}
```

works for this XML:

```xml
<book id="123">
    <id>123</id>
    <title>Cat in the Hat</title>
    <category>Kids</category>
    <category>Wildlife</category>
</book>
```

### Coding key value intrinsic

Suppose that you need to decode an XML that looks similar to this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<foo id="123">456</foo>
```

By default you'd be able to decode `foo` as an element, but then it's not 
possible to decode the `id` attribute. `XMLCoder` handles certain `CodingKey`
values in a special way to allow proper coding for this XML. Just add a coding
key with `stringValue` that equals `"value"` or `""` (empty string). What
follows is an example type declaration that encodes the XML above, but special
handling of coding keys with those values works for both encoding and decoding.

```swift
struct Foo: Codable, DynamicNodeEncoding {
    let id: String
    let value: String

    enum CodingKeys: String, CodingKey {
        case id
        case value
        // case value = "" would also work
    }

    static func nodeEncoding(forKey key: CodingKey) 
    -> XMLEncoder.NodeEncoding {
        switch key {
        case CodingKeys.id:
            return .attribute
        default:
            return .element
        }
    }
}
```

### Preserving whitespaces in element content

By default whitespaces are trimmed in element content during decoding. This
includes string values decoded with [value intrinsic keys](#coding-key-value-intrinsic). Starting with version 0.5 you can now set a
property `trimValueWhitespaces` to `false` (the default value is `true`) on
`XMLDecoder` instance to preserve all whitespaces in decoded strings.

## Installation

### Requirements

- Xcode 10.0 or later
- Swift 4.2 or later
- iOS 9.0 / watchOS 2.0 / tvOS 9.0 / macOS 10.10 or later

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Swift and Objective-C Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

Navigate to the project directory and create `Podfile` with the following command:

```bash
$ pod install
```

Inside of your `Podfile`, specify the `XMLCoder` pod:

```ruby
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'YourApp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Test
  pod 'XMLCoder', '~> 0.5.1'

end
```

Then, run the following command:

```bash
$ pod install
```

Open the the `YourApp.xcworkspace` file that was created. This should be the
file you use everyday to create your app, instead of the `YourApp.xcodeproj`
file.

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a dependency manager that builds your dependencies and provides you with binary frameworks.

Carthage can be installed with [Homebrew](https://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

Inside of your `Cartfile`, add GitHub path to `XMLCoder`:

```ogdl
github "MaxDesiatov/XMLCoder" ~> 0.5.1
```

Then, run the following command to build the framework:

```bash
$ carthage update
```

Drag the built framework into your Xcode project.

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for
managing the distribution of Swift code. It’s integrated with the Swift build
system to automate the process of downloading, compiling, and linking
dependencies.

Once you have your Swift package set up, adding `XMLCoder` as a dependency is as
easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.5.1")
]
```

## Contributing

This project adheres to the [Contributor Covenant Code of
Conduct](https://github.com/MaxDesiatov/XMLCoder/blob/master/CODE_OF_CONDUCT.md).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to xmlcoder@desiatov.com.

### Coding Style

This project uses [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) to
enforce formatting style. We encourage you to run SwiftFormat within a local
clone of the repository in whatever way works best for you either manually or
automatically via an [Xcode
extension](https://github.com/nicklockwood/SwiftFormat#xcode-source-editor-extension),
[build phase](https://github.com/nicklockwood/SwiftFormat#xcode-build-phase) or
[git pre-commit
hook](https://github.com/nicklockwood/SwiftFormat#git-pre-commit-hook) etc.
Please check [SwiftFormat
documentation](https://github.com/nicklockwood/SwiftFormat#how-do-i-install-it)
for more details.

SwiftFormat also runs within our [Travis
CI](https://travis-ci.org/MaxDesiatov/XMLCoder) setup and a CI build can fail
with incosistent formatting. We require CI builds to pass for any PR before
merging.

### Test Coverage

Our goal is to keep XMLCoder stable and to serialize any XML correctly according
to [XML 1.0 standard](https://www.w3.org/TR/2008/REC-xml-20081126/). All of this
can be easily tested automatically and we're slowly improving [test coverage of
XMLCoder](https://codecov.io/gh/MaxDesiatov/XMLCoder) and don't expect it to
decrease. PRs that decrease the test coverage have a much lower chance of being
merged. If you add any new features, please make sure to add tests, likewise for
changes and any refactoring in existing code.
