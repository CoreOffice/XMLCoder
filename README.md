# XMLParsing
Encoder &amp; Decoder for XML using Swift's _codable_ protocol.

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Swift and Objective-C Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

Navigate to the project directory and create a _podfile_ with the following command:

```bash
$ pod install
```

Inside of your `Podfile`, specify the XMLParsing pod:

```ruby
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'YourApp' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Test
  pod 'XMLParsing', :git => 'https://github.com/ShawnMoore/XMLParsing.git'

end
```

Then, run the following command:

```bash
$ pod install
```

Open the the _xcworkspace_ file that was created. This should be the file you use everyday to create your app, instead of the _xcodeproj_ file.

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a dependency manager that builds your dependencies and provides you with binary frameworks.

Carthage can be installed with [Homebrew](https://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

Inside of your `Cartfile`, specify XMLParsing:

```ogdl
github "ShawmMoore/XMLParsing"
```

Then, run the following command to build the framework:

```bash
$ carthage update
```

Drag the built framework into your Xcode project.

### Swift Package Manager

[Swift Package Manager](https://swift.org/package-manager/) is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

Once you have your Swift package set up, adding XMLParsing as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/ShawnMoore/XMLParsing.git", from: "0.0.3")
]
```

## Example

```swift
import XMLParsing

let xmlStr = """
<note>
    <to>Bob</to>
    <from>Jane</from>
    <heading>Reminder</heading>
    <body>Don't forget to use XMLParsing!</body>
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
