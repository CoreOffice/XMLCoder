# 0.8.0 (August 4, 2019)

This release adds support for decoding and encoding ordered sequences of
different elements as enums with associated values. In addition, XMLCoder now
supports Linux. Many thanks to [@jsbean](https://github.com/jsbean),
[@bwetherfield](https://github.com/bwetherfield) and
[@drewag](https://github.com/drewag) for implementing this!

**Breaking changes:**

- Fixed typo in `XMLDecoder` property: `errorContextLenght` has been renamed to `errorContextLength` in [\#114](https://github.com/MaxDesiatov/XMLCoder/pull/114).

**Closed issues:**

- XML with autoclosed tags [\#116](https://github.com/MaxDesiatov/XMLCoder/issues/116)
- Arrays of enums [\#91](https://github.com/MaxDesiatov/XMLCoder/issues/91)
- Array of enums with associated values [\#25](https://github.com/MaxDesiatov/XMLCoder/issues/25)

**Merged pull requests:**

- Decoding choice elements that can hold empty structs
  [\#120](https://github.com/MaxDesiatov/XMLCoder/pull/120)
  ([@bwetherfield](https://github.com/bwetherfield))
- `Encodable` and `Decodable` support for choice elements
  [\#119](https://github.com/MaxDesiatov/XMLCoder/pull/119)
  ([@jsbean](https://github.com/jsbean))
- Add Linux support [\#117](https://github.com/MaxDesiatov/XMLCoder/pull/117)
  ([@drewag](https://github.com/drewag))
- Fix typo: `errorContextLenght` -\> `errorContextLength`
  [\#114](https://github.com/MaxDesiatov/XMLCoder/pull/114)
  ([@jsbean](https://github.com/jsbean))

# 0.7.0 (July 2, 2019)

This release changes the behavior of attributes coding: now order of XML
attributes is fully preserved. One of the benefits is that it improves unit
testing for users of XMLCoder, which allows testing against specific encoded
attributes without accounting for their randomized order. Also a small coding
style fix is included. In addition, XMLCoder now uses Azure Pipelines instead of
Travis for CI with great improvements to overall CI stability, speed, and
parallel builds. Thanks to [Andrés Cecilia Luque](https://github.com/acecilia)
and [Jay Hickey](https://github.com/jayhickey) for the contributions!

**Merged pull requests:**

- Change components variable from var to let
  [\#107](https://github.com/MaxDesiatov/XMLCoder/pull/107)
  ([@jayhickey](https://github.com/jayhickey))
- Keep the order of the attributes during encoding operations
  [\#110](https://github.com/MaxDesiatov/XMLCoder/pull/110)
  ([@acecilia](https://github.com/acecilia))
- Migrate from Travis to Azure Pipelines
  [\#111](https://github.com/MaxDesiatov/XMLCoder/pull/111)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.6.0 (June 17, 2019)

An improvement release that introduces `convertFromKebabCase` and
`convertToKebabCase` key decoding strategies. There were a few changes that
aren't visible to end-users: the way that keys and values are stored internally
has changed and a few more tests added. Thanks to [Andrés Cecilia
Luque](https://github.com/acecilia) and [Vincent
Esche](https://github.com/regexident) for the contributions!

**Merged pull requests:**

- Add support for kebab-case KeyDecodingStrategy
  [\#105](https://github.com/MaxDesiatov/XMLCoder/pull/105)
  ([@acecilia](https://github.com/acecilia))
- Replace UnkeyedBox with Array, refine KeyedStorage
  [\#102](https://github.com/MaxDesiatov/XMLCoder/pull/102)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Add tests for nested keyed/unkeyed collections
  [\#38](https://github.com/MaxDesiatov/XMLCoder/pull/38)
  ([@regexident](https://github.com/regexident))

# 0.5.1 (May 2, 2019)

Bugfix release that restores decoding of empty sequences, which became broken in
0.5.0.

**Merged pull requests:**

- Fix decoding of empty sequences
  [\#98](https://github.com/MaxDesiatov/XMLCoder/pull/98)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Rename `flatten` to `transformToBoxTree`, rename tests
  [\#97](https://github.com/MaxDesiatov/XMLCoder/pull/97)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.5.0 (May 2, 2019)

A small improvement release tagged early to resolve blocking issues in
[CoreXLSX](https://github.com/MaxDesiatov/CoreXLSX). 

**Notable changes:**

* Empty value strings are no longer decoded as `nil` when a `String` is
  expected, but are decoded as empty strings, which represents the actual value.
* `trimValueWhitespaces` property was added on `XMLDecoder`, which allows
  overriding the default behaviour, where starting and trailing whitespaces are
  trimmed from string values.

**Closed issues:**

- Trimmed whitespace on decoding `String`
  [\#94](https://github.com/MaxDesiatov/XMLCoder/issues/94)

**Merged pull requests:**

- Fixed a bug when decoding a key with one character only
  [\#96](https://github.com/MaxDesiatov/XMLCoder/pull/96)
  ([@TheFlow95](https://github.com/TheFlow95))
- Add more cases to `AttributedIntrinsicTest`
  [\#95](https://github.com/MaxDesiatov/XMLCoder/pull/95)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Use `map` instead of `mapValues`/`shuffle` in `XMLCoderElement.flatten`
  [\#93](https://github.com/MaxDesiatov/XMLCoder/pull/93)
  ([@jsbean](https://github.com/jsbean))
- Fix decoding empty element as optional
  [\#92](https://github.com/MaxDesiatov/XMLCoder/pull/92)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.4.1 (April 12, 2019)

A bugfix release removing unused Xcode project scheme to improve build time
for Carthage users.

**Notable changes:**

* Remove unused scheme in Xcode project ([@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.4.0 (April 8, 2019)

This is a release with plenty of new features that allow you to parse many more
XML variations than previously. Compatibility with Xcode 10.2 and Swift 5.0 is
also improved. A huge thank you to [@JoeMatt](https://github.com/JoeMatt) and
[@regexident](https://github.com/regexident) for their contributions, to
[@hodovani](https://github.com/hodovani) for maintaining the project, and to
[@Inukinator](https://github.com/Inukinator),
[@qmoya](https://github.com/qmoya), [@Ma-He](https://github.com/Ma-He),
[@khoogheem](https://github.com/khoogheem) and
[@thecb4](https://github.com/thecb4) for reporting issues during development!

**Notable changes:**

* Ordered encoding: this was one of the most requested changes and it's finally
  here! 🎉 Now both keyed and unkeyed elements are encoded in the exactly same
  order that was used in original containers. This is applicable to both
  compiler-generated encoding implementations (just reorder properties or cases
  in your `CodingKeys` enum if you have it) and manually implemented `func
  encode(to: Encoder)`.
* Stripping namespace prefix: now if your coding key string values contain an
  XML namespace prefix (e.g. prefix `h` in `<h:td>Apples</h:td>`), you [can
  set](https://github.com/MaxDesiatov/XMLCoder/blob/3944866/README.md#stripping-namespace-prefix)
  `shouldProcessNamespaces` property to `true` on your `XMLDecoder` instance for
  the prefix to be stripped before decoding keys in your `Decodable` types.
* Previously it was possible to customize encoding with `NodeEncodingStrategy`,
  but no such type existed for decoding. A corresponding `NodeDecodingStrategy`
  type was added with `nodeDecodingStrategy` property on `XMLDecoder`.
* Thanks to the previous change, XMLCoder now provides two helper protocols that
  allow you to easily customize whether nodes are encoded and decoded as
  attributes or elements for conforming types: [`DynamicNodeEncoding` and
  `DynamicNodeDecoding`](https://github.com/MaxDesiatov/XMLCoder/blob/3944866/README.md#dynamic-node-coding).
* Previously if you needed to decode or encode an XML element with both
  attributes and values, this was impossible to do with XMLCoder. Now with the
  addition of [coding key value
  intrinsic](https://github.com/MaxDesiatov/XMLCoder/blob/3944866/README.md#coding-key-value-intrinsic),
  this is as easy as adding one coding key with a specific string raw value
  (`"value"` or empty string `""` if you already have an XML attribute named
  `"value"`).

**Closed issues:**

- Crash: Range invalid bounds in XMLStackParser.swift [\#83](https://github.com/MaxDesiatov/XMLCoder/issues/83)
- Document DynamicNodeEncoding and attributed intrinsic [\#80](https://github.com/MaxDesiatov/XMLCoder/issues/80)
- Fix nested attributed intrinsic  [\#78](https://github.com/MaxDesiatov/XMLCoder/issues/78)
- nodeEncodingStrategy [\#49](https://github.com/MaxDesiatov/XMLCoder/issues/49)
- XmlEncoder: ordering of elements [\#17](https://github.com/MaxDesiatov/XMLCoder/issues/17)
- Can’t reach an XML value [\#12](https://github.com/MaxDesiatov/XMLCoder/issues/12)

**Merged pull requests:**

- Make value intrinsic smarter
  [\#89](https://github.com/MaxDesiatov/XMLCoder/pull/89)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Refactor XMLCoderElement.flatten, add tests
  [\#88](https://github.com/MaxDesiatov/XMLCoder/pull/88)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Add separate lint stage to .travis.yml
  [\#87](https://github.com/MaxDesiatov/XMLCoder/pull/87)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Add multiple Xcode versions to Travis build matrix
  [\#86](https://github.com/MaxDesiatov/XMLCoder/pull/86)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Add DynamicNodeDecoding protocol
  [\#85](https://github.com/MaxDesiatov/XMLCoder/pull/85)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Improve tests and fix error context handling
  [\#84](https://github.com/MaxDesiatov/XMLCoder/pull/84)
  ([MaxDesiatov](https://github.com/MaxDesiatov))
- Ordered encoding [\#82](https://github.com/MaxDesiatov/XMLCoder/pull/82)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Add `shouldProcessNamespaces` decoder property
  [\#81](https://github.com/MaxDesiatov/XMLCoder/pull/81)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Fix nested attributed intrinsic
  [\#79](https://github.com/MaxDesiatov/XMLCoder/pull/79)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Fix compatibility with Swift 5.0
  [\#77](https://github.com/MaxDesiatov/XMLCoder/pull/77)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Attributed Intrinsic \(value coding key\)
  [\#73](https://github.com/MaxDesiatov/XMLCoder/pull/73)
  ([@JoeMatt](https://github.com/JoeMatt))
- Dynamic node encoding + new formatters + various fixes
  [\#70](https://github.com/MaxDesiatov/XMLCoder/pull/70)
  ([@JoeMatt](https://github.com/JoeMatt))
- Add `NodeDecodingStrategy`, mirroring `NodeEncodingStrategy `
  [\#45](https://github.com/MaxDesiatov/XMLCoder/pull/45)
  ([@regexident](https://github.com/regexident))

# 0.3.1 (February 6, 2019)

A bugfix release that adds missing `CFBundleVersion` in generated framework's 
`Info.plist` ([#72](https://github.com/MaxDesiatov/XMLCoder/issues/72) reported by 
[@stonedauwg](https://github.com/stonedauwg)).

**Changes:**

* Set `CURRENT_PROJECT_VERSION` in project file ([#74](https://github.com/MaxDesiatov/XMLCoder/pull/74), [@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.3.0 (January 22, 2019)

A maintenance release focused on fixing bugs, improving error reporting and
overall internal architecture of the library. For this release we've started
tracking test coverage and were able to increase it from 11.8% to 75.6%. 🎉
Thanks to [@hodovani](https://github.com/hodovani) and
[@regexident](https://github.com/regexident) for their work on improving test
coverage in this release.

**Additions:**

You can now set `errorContextLength: UInt` property on `XMLDecoder` instance,
which will make it add a snippet of XML of at most this length from parser state
when a parsing error occurs. This change was provided by
[@hodovani](https://github.com/hodovani) and  can greatly help with attempts to
parse invalid XML, where previously only a line and column number were reported.

**Deprecations:**

`NodeEncodingStrategies` was renamed to `NodeEncodingStrategy` for consistency.
`NodeEncodingStrategies` is still available as a deprecated typealias, which
will be removed in future versions. Thanks to
[@regexident](https://github.com/regexident) for cleaning this up and providing
many more changes in this release that make `XMLCoder` better and easier to use.

**Changes:**

* Add SwiftLint and fix linter errors
  ([#35](https://github.com/MaxDesiatov/XMLCoder/pull/35),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
* Add single array element example to tests
  ([#66](https://github.com/MaxDesiatov/XMLCoder/pull/66),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
* Remove generic encode/decode functions
  ([#64](https://github.com/MaxDesiatov/XMLCoder/pull/64),
  [@hodovani](https://github.com/hodovani))
* Change internal representation to ordered array of children
  ([#55](https://github.com/MaxDesiatov/XMLCoder/pull/55),
  [@regexident](https://github.com/regexident))
* Keyed/unkeyed boxes as structs
  ([#36](https://github.com/MaxDesiatov/XMLCoder/pull/36),
  [@regexident](https://github.com/regexident))
* Add dedicated benchmarking test suite
  ([#34](https://github.com/MaxDesiatov/XMLCoder/pull/34),
  [@regexident](https://github.com/regexident))
* Add tests to increase test coverage
  ([#63](https://github.com/MaxDesiatov/XMLCoder/pull/63),
  [@hodovani](https://github.com/hodovani))
* Add tests for keyed and unkeyed int types
  ([#62](https://github.com/MaxDesiatov/XMLCoder/pull/62),
  [@hodovani](https://github.com/hodovani))
* Add test to case when error context size goes outside content size
  ([#61](https://github.com/MaxDesiatov/XMLCoder/pull/61),
  [@hodovani](https://github.com/hodovani))
* Specify Swift version for packaging, refine CI
  ([#60](https://github.com/MaxDesiatov/XMLCoder/pull/60),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
* Add test for keyed Int types
  ([#58](https://github.com/MaxDesiatov/XMLCoder/pull/58),
  [@hodovani](https://github.com/hodovani))
* Fix missing trailing semicolon in character escapings
  ([#59](https://github.com/MaxDesiatov/XMLCoder/pull/59),
  [@regexident](https://github.com/regexident))
* Increase test coverage
  ([#56](https://github.com/MaxDesiatov/XMLCoder/pull/56),
  [@hodovani](https://github.com/hodovani))
* Fix `RelationshipsTest.testDecoder` crash on failure
  ([#50](https://github.com/MaxDesiatov/XMLCoder/pull/50),
  [@regexident](https://github.com/regexident))
* Improve `XMLStackParserTests` to test against CDATA blocks
  ([#51](https://github.com/MaxDesiatov/XMLCoder/pull/51),
  [@regexident](https://github.com/regexident))
* Remove unnecessary use of `@available(…)` for `OutputFormatting.sortedKeys`
  ([#53](https://github.com/MaxDesiatov/XMLCoder/pull/53),
  [@regexident](https://github.com/regexident))
* Fix decoding of arrays with optional elements
  ([#48](https://github.com/MaxDesiatov/XMLCoder/pull/48),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
* Add Optional Error Context
  ([#46](https://github.com/MaxDesiatov/XMLCoder/pull/46),
  [@hodovani](https://github.com/hodovani))
* Install Carthage only in before_deploy on Travis
  ([#47](https://github.com/MaxDesiatov/XMLCoder/pull/47),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
* Add coding style and test coverage to README.md
  ([#44](https://github.com/MaxDesiatov/XMLCoder/pull/44),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
* Improve code coverage of auxiliary types
  ([#43](https://github.com/MaxDesiatov/XMLCoder/pull/43),
  [@regexident](https://github.com/regexident))
* Improve code coverage of box types
  ([#42](https://github.com/MaxDesiatov/XMLCoder/pull/42),
  [@regexident](https://github.com/regexident))
* Make error handling in `XMLDecoder` simpler & safer
  ([#41](https://github.com/MaxDesiatov/XMLCoder/pull/41),
  [@regexident](https://github.com/regexident))
* Unfold `guard … else` blocks to allow settingbreakpoints
  ([#39](https://github.com/MaxDesiatov/XMLCoder/pull/39),
  [@regexident](https://github.com/regexident))
* Cleanup throwing unit tests & add tests for missing values
  ([#40](https://github.com/MaxDesiatov/XMLCoder/pull/40),
  [@regexident](https://github.com/regexident))
* Let compiler synthesize Equatable conformance for _XMLElement
  ([#33](https://github.com/MaxDesiatov/XMLCoder/pull/33),
  [@jsbean](https://github.com/jsbean))
* Apply SwiftFormat on CI runs
  ([#32](https://github.com/MaxDesiatov/XMLCoder/pull/32),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
* Fix a bug with throws on `Encodable` encoding nothing
  ([#31](https://github.com/MaxDesiatov/XMLCoder/pull/31),
  [@regexident](https://github.com/regexident))
* Clean up `XMLElement`, `ArrayBox` & `DictionaryBox`
  ([#28](https://github.com/MaxDesiatov/XMLCoder/pull/28),
  [@regexident](https://github.com/regexident))
* Extract URL coding into `URLBox` with tests
  ([#30](https://github.com/MaxDesiatov/XMLCoder/pull/30),
  [@regexident](https://github.com/regexident))
* Remove use of explicit `internal`
  ([#29](https://github.com/MaxDesiatov/XMLCoder/pull/29),
  [@regexident](https://github.com/regexident))
* Clean up coding logic, improve box naming
  ([#27](https://github.com/MaxDesiatov/XMLCoder/pull/27),
  [@regexident](https://github.com/regexident))
* Clean up `XMLStackParser`
  ([#26](https://github.com/MaxDesiatov/XMLCoder/pull/26),
  [@regexident](https://github.com/regexident))
* Overhaul internal representation, replacing `NS…` with `…Box` types
  ([#19](https://github.com/MaxDesiatov/XMLCoder/pull/19),
  [@regexident](https://github.com/regexident))
* Added benchmark to RJI test suite
  ([#20](https://github.com/MaxDesiatov/XMLCoder/pull/20),
  [@regexident](https://github.com/regexident))
* Fix generation of Jazy docs
  ([#18](https://github.com/MaxDesiatov/XMLCoder/pull/18),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
* Added unit tests for array and dictionary properties
  ([#7](https://github.com/MaxDesiatov/XMLCoder/pull/7),
  [@regexident](https://github.com/regexident))
* Moved `_XML…EncodingContainer` into their own files, matching decoder
  ([#4](https://github.com/MaxDesiatov/XMLCoder/pull/4),
  [@regexident](https://github.com/regexident))
* Convert `Sample XML` code to XCTest
  ([#1](https://github.com/MaxDesiatov/XMLCoder/pull/1),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
* Respect .sortedKeys option, add .swiftformat
  ([@qmoya](https://github.com/qmoya))
* Bring back `gem install cocoapods --pre` to Travis
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
* Add --verbose flag to `pod lib lint` in travis.yml
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
* Specify stable versions in the installation guide
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
* Implement Travis CI deployment of Carthage archive
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
* Add NodeEncodingStrategies typelias as deprecated
  ([#9](https://github.com/MaxDesiatov/XMLCoder/pull/9),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
* Rename `NodeEncodingStrategies` to match other type names
  ([#8](https://github.com/MaxDesiatov/XMLCoder/pull/8),
  [@regexident](https://github.com/regexident))
* Consider node encoding strategy for values inside unkeyed containers
  ([#2](https://github.com/MaxDesiatov/XMLCoder/pull/2),
  [@regexident](https://github.com/regexident))
* Run tests with coverage, upload to codecov.io
  ([@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.2.1 (November 18, 2018)

* watchOS deployment target set to 2.0 for Carthage ([@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.2.0 (November 18, 2018)

* Add watchOS 2.0 deployment target ([@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.1.1 (November 18, 2018)

* Set iOS deployment target to 9.0 ([@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.1.0 (November 8, 2018)

* Add support for decoupled, type-dependent node-encoding strategies
  ([@regexident](https://github.com/regexident))
* Add missing visibility declarations
  ([@regexident](https://github.com/regexident))
* Improve `.gitignore` and remove tracked `*.xcuserdata` files
  ([@regexident](https://github.com/regexident))
* Make `XMLEncoder.OutputFormatting.prettyPrinted` actually do something
  ([@regexident](https://github.com/regexident))
* Add tvOS deployment target to podspec ([@edc1591](https://github.com/edc1591))
* Fix Carthage command ([@salavert](https://github.com/salavert))
* Set deployment versions to allow older SDKs
  ([@Lutzifer](https://github.com/Lutzifer))
* Add Info.plist to allow Framework use in App Store Connect via Carthage
  ([@Lutzifer](https://github.com/Lutzifer))
* Set `CURRENT_PROJECT_VERSION`  ([@Lutzifer](https://github.com/Lutzifer))
* Add `convertFromCapitalized` strategy, simple test
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
* Allow older iOS/tvOS deployment targets in podspec
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
