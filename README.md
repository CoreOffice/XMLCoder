# XMLCoder
Encoder &amp; Decoder for XML using Swift's `Codable` protocols.

[![CI Status](https://img.shields.io/travis/MaxDesiatov/XMLCoder/master.svg?style=flat)](https://travis-ci.org/MaxDesiatov/XMLCoder)
[![Version](https://img.shields.io/cocoapods/v/XMLCoder.svg?style=flat)](https://cocoapods.org/pods/XMLCoder)
[![License](https://img.shields.io/cocoapods/l/XMLCoder.svg?style=flat)](https://cocoapods.org/pods/XMLCoder)
[![Platform](https://img.shields.io/cocoapods/p/XMLCoder.svg?style=flat)](https://cocoapods.org/pods/XMLCoder)
[![Coverage](https://img.shields.io/codecov/c/github/MaxDesiatov/XMLCoder/master.svg?style=flat)](https://codecov.io/gh/maxdesiatov/XMLCoder)

This package is a fork of the original
[ShawnMoore/XMLParsing](https://github.com/ShawnMoore/XMLParsing)
with more options and tests added.

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
    var to: String
    var from: String
    var heading: String
    var body: String
}

guard let data = xmlStr.data(using: .utf8) else { return }

let note = try? XMLDecoder().decode(Note.self, from: data)

let returnData = try? XMLEncoder().encode(note, withRootKey: "note")
```

## Installation

## Requirements

- Xcode 10
- Swift 4.2
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
  pod 'XMLCoder', '~> 0.3.1'

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
github "MaxDesiatov/XMLCoder" ~> 0.3.1
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
    .package(url: "https://github.com/MaxDesiatov/XMLCoder.git", from: "0.3.1")
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
