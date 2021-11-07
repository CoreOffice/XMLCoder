# 0.13.1 (7 November 2021)

This is a bugfix release that fixes an edge case with the use of `trimValueWhitespaces` configuration on
`XMLDecoder`, and adds official Windows support for users of Swift 5.5. Many thanks to
[@MartinP7r](https://github.com/MartinP7r) for multiple contributions to this release!

**Closed issues:**

- Encoding an Attribute doesn't work anymore ([#231](https://github.com/MaxDesiatov/XMLCoder/issues/231))
- How to "skip" certain XML tags / element in a TCX file ([#227](https://github.com/MaxDesiatov/XMLCoder/issues/227))
- Encode element with empty key, no elements, and attributes ([#224](https://github.com/MaxDesiatov/XMLCoder/issues/224))

**Merged pull requests:**

- Add Windows to GitHub Actions CI build matrix ([#233](https://github.com/MaxDesiatov/XMLCoder/pull/233)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add test for preserved spaces with XML entities ([#234](https://github.com/MaxDesiatov/XMLCoder/pull/234)) via [@MartinP7r](https://github.com/MartinP7r)
- Fix `trimValueWhitespaces` removing needed white-spaces ([#226](https://github.com/MaxDesiatov/XMLCoder/pull/226)) via [@MartinP7r](https://github.com/MartinP7r)
- Remove some of the SwiftLint generated warnings ([#229](https://github.com/MaxDesiatov/XMLCoder/pull/229)) via [@MartinP7r](https://github.com/MartinP7r)
- Remove unneeded parameter `key` ([#225](https://github.com/MaxDesiatov/XMLCoder/pull/225)) via [@MartinP7r](https://github.com/MartinP7r)

# 0.13.0 (6 August 2021)

This release adds two new features and a bugfix.

Namely:

- `removeWhitespaceElements` boolean flag on `XMLDecoder` allows removing elements that have
  purely whitespace content.
- `convertFromUppercase` case on `KeyDecodingStrategy` allows converting `ALL_CAPS_SNAKE_CASE` to
  `camelCase`.
- an edge case in intrinsic key value decoding has been fixed.

Many thanks to [@huwr](https://github.com/huwr), [@kneekey23](https://github.com/kneekey23), and
[@wooj2](https://github.com/wooj2) for their contributions!

**Closed issues:**

- Decoding special whitespace characters ([#219](https://github.com/MaxDesiatov/XMLCoder/issues/219))
- Help with mix of attributes and elements ([#212](https://github.com/MaxDesiatov/XMLCoder/issues/212))

**Merged pull requests:**

- Encode element with empty key, empty element, and attributes ([#223](https://github.com/MaxDesiatov/XMLCoder/pull/223)) via [@wooj2](https://github.com/wooj2)
- Implement `removeWhitespaceElements ` on `XMLDecoder` ([#222](https://github.com/MaxDesiatov/XMLCoder/pull/222)) via [@wooj2](https://github.com/wooj2)
- Add convert from UPPERCASE decoding key strategy ([#214](https://github.com/MaxDesiatov/XMLCoder/pull/214)) via [@huwr](https://github.com/huwr)

# 0.12.0 (26 January 2021)

This release adds a few new features. Namely:

- New `charactersEscapedInAttributes` and `charactersEscapedInElements` properties on `XMLEncoder`
  that allow customizing how certain characters are escaped.
- You can now override the implementation of `TopLevelEncoder` Combine protocol conformance when
  subclassing `XMLEncoder`.
- New `prettyPrintIndentation` property on `XMLEncoder`, which can take `XMLEncoder.PrettyPrintIndentation` values such as `.tabs(1)` or `.spaces(2)`.

Thanks to [Kenta Kubo](https://github.com/kkk669) for the contribution!

**Closed issues:**

- How to decode `<itunes:episode>` tags ([#201](https://github.com/MaxDesiatov/XMLCoder/issues/201))
- Fail to build in Xcode 12 beta ([#196](https://github.com/MaxDesiatov/XMLCoder/issues/196))
- Changing the root node name ? ([#191](https://github.com/MaxDesiatov/XMLCoder/issues/191))
- " in XML element may not always be escaping ([#187](https://github.com/MaxDesiatov/XMLCoder/issues/187))
- `&#10;` in XML attributes ([#185](https://github.com/MaxDesiatov/XMLCoder/issues/185))
- " and `&quot;` are not decoded equally ([#184](https://github.com/MaxDesiatov/XMLCoder/issues/184))
- Use 2 spaces instead of 4 when .prettyPrinted ([#183](https://github.com/MaxDesiatov/XMLCoder/issues/183))
- (Help using) How to decode this XML? ([#180](https://github.com/MaxDesiatov/XMLCoder/issues/180))

**Merged pull requests:**

- Test `DynamicNodeEncoding` for root elements ([#195](https://github.com/MaxDesiatov/XMLCoder/pull/195)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Make character escaping customizable in `XMLEncoder` ([#188](https://github.com/MaxDesiatov/XMLCoder/pull/188)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add `prettyPrintIndentation` property on `XMLEncoder` ([#186](https://github.com/MaxDesiatov/XMLCoder/pull/186)) via [@MaxDesiatov](https://github.com/MaxDesiatov)
- Make `TopLevelEncoder` implementation overridable ([#182](https://github.com/MaxDesiatov/XMLCoder/pull/182)) via [@kkk669](https://github.com/kkk669)

# 0.11.1 (3 May 2020)

This release fixes an issue, where non-string values used CDATA encoding.
Thanks to [@ksoftllc](https://github.com/ksoftllc) for reporting it!

**Closed issues:**

- Non-string values are being encoded as CData
  ([#178](https://github.com/MaxDesiatov/XMLCoder/issues/178))
- How to encode as an empty element
  ([#177](https://github.com/MaxDesiatov/XMLCoder/issues/177))

**Merged pull requests:**

- Encode only strings as CDATA
  ([#179](https://github.com/MaxDesiatov/XMLCoder/pull/179))
  [@MaxDesiatov](https://github.com/MaxDesiatov)

# 0.11.0 (13 April 2020)

This is a bugfix and feature release, which fixes [an issue with CDATA
decoding](https://github.com/MaxDesiatov/XMLCoder/issues/168)
and adds [`TopLevelEncoder` conformance to
`XMLEncoder`](https://github.com/MaxDesiatov/XMLCoder/pull/175). New
[`rootAttributes` argument](https://github.com/MaxDesiatov/XMLCoder/pull/160)
has been added to the `encode` function on `XMLEncoder` that allows
adding attributes on root elements without adding them to your model types.
Thanks to [@portellaa](https://github.com/portellaa),
[@Kirow](https://github.com/Kirow) and others for their contributions and
bug reports!

**Closed issues:**

- CDATA Decoding not working
  ([#168](https://github.com/MaxDesiatov/XMLCoder/issues/168))
- Decode special XML Structure
  ([#156](https://github.com/MaxDesiatov/XMLCoder/issues/156))
- Root level attributes don't get encoded back to attribute when converting back to XML file from Plist
  ([#127](https://github.com/MaxDesiatov/XMLCoder/issues/127))
- Bad access error when running on device
  ([#100](https://github.com/MaxDesiatov/XMLCoder/issues/100))

**Merged pull requests:**

- Add TopLevelEncoder implementation
  ([#175](https://github.com/MaxDesiatov/XMLCoder/pull/175))
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Add support for root attributes propagation
  ([#160](https://github.com/MaxDesiatov/XMLCoder/pull/160))
  [@portellaa](https://github.com/portellaa)
- Fix RJITest RSS encoding and decoding
  ([#171](https://github.com/MaxDesiatov/XMLCoder/pull/171))
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Cleanup tests, support OpenCombine
  ([#169](https://github.com/MaxDesiatov/XMLCoder/pull/169))
  [@MaxDesiatov](https://github.com/MaxDesiatov)
- Fix CDATA issue
  ([#170](https://github.com/MaxDesiatov/XMLCoder/pull/170))
  [@MaxDesiatov](https://github.com/MaxDesiatov)

# 0.10.0 (4 April 2020)

This is a bugfix release, which improves encoding and decoding of enums with associated values
(also known as "choice coding") with the `XMLChoiceCodingKey` protocol. This release is also
tested on Xcode 11.4 and Swift 5.2.1 on Linux. A few breaking changes were introduced, which were
needed to simplify and improve internals of the library. Please refer to the corresponding section
below for more details. Thanks to [@bwetherfield](https://github.com/bwetherfield) and
[@ultramiraculous](https://github.com/ultramiraculous) for their contributions!

**Breaking changes:**

- Fix Decoding of Arrays of Empty Elements
  ([#152](https://github.com/MaxDesiatov/XMLCoder/pull/152))
  ([@bwetherfield](https://github.com/bwetherfield))

This change was needed to accommodate for multiple edges cases with how arrays of empty elements
and empty strings are decoded.

- Replace value intrinsic with empty string key
  ([#149](https://github.com/MaxDesiatov/XMLCoder/pull/149))
  ([@bwetherfield](https://github.com/bwetherfield))

The value intrinsic now only accepts the empty string key `""`, as the previous `"value"` key
caused naming collisions with attributes and elemenents that had the same name.

**Closed issues:**

- Bundle identifier in wrong format
  ([#164](https://github.com/MaxDesiatov/XMLCoder/issues/164))
- Can inheritance be implemented?
  ([#159](https://github.com/MaxDesiatov/XMLCoder/issues/159))
- EXC_BAD_ACCESS when running tests
  ([#153](https://github.com/MaxDesiatov/XMLCoder/issues/153))
- EXC_BAD_ACCESS on XCode 11.2 and iOS13.2
  ([#150](https://github.com/MaxDesiatov/XMLCoder/issues/150))
- Date formatting on 24h region with display set to 12h
  ([#148](https://github.com/MaxDesiatov/XMLCoder/issues/148))
- Decoding containers with (potentially)-empty elements
  ([#123](https://github.com/MaxDesiatov/XMLCoder/issues/123))

**Merged pull requests:**

- Run GitHub Actions on a push to the master branch
  ([#167](https://github.com/MaxDesiatov/XMLCoder/pull/167))
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Test w/ Xcode 11.4 on macOS, Swift 5.2.1 on Linux
  ([#166](https://github.com/MaxDesiatov/XMLCoder/pull/166))
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Use reverse-DNS notation for the bundle identifier
  ([#165](https://github.com/MaxDesiatov/XMLCoder/pull/165))
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Trigger Azure Pipelines run on PRs to master
  ([#162](https://github.com/MaxDesiatov/XMLCoder/pull/162))
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Run Danger with GitHub Actions
  ([#163](https://github.com/MaxDesiatov/XMLCoder/pull/163))
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Trigger Azure Pipelines run on PRs to master
  ([#162](https://github.com/MaxDesiatov/XMLCoder/pull/162))
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Add Xcode 11.3 to azure-pipelines.yml
  ([#158](https://github.com/MaxDesiatov/XMLCoder/pull/158))
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Support for mixed-content nodes
  ([#157](https://github.com/MaxDesiatov/XMLCoder/pull/157))
  ([@ultramiraculous](https://github.com/ultramiraculous))
- Mixed choice/non-choice decoding
  ([#155](https://github.com/MaxDesiatov/XMLCoder/pull/155))
  ([@bwetherfield](https://github.com/bwetherfield))
- Mixed choice/non-choice encoding
  ([#154](https://github.com/MaxDesiatov/XMLCoder/pull/154))
  ([@bwetherfield](https://github.com/bwetherfield))
- Add Xcode 11.2 and 10.3 to azure-pipelines.yml
  ([#151](https://github.com/MaxDesiatov/XMLCoder/pull/151))
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Fix Decoding of Empty String
  ([#145](https://github.com/MaxDesiatov/XMLCoder/pull/145))
  ([@bwetherfield](https://github.com/bwetherfield))

# 0.9.0 (19 October 2019)

This release fixes a few bugs with `Float` type parsing and Swift 5.1 support on
Linux. It also adds a helper extension to improve compatibility with Combine and
adds a few tests to confirm that a few edges cases are working well. Thanks to
[@bwetherfield](https://github.com/bwetherfield),
[@DJBen](https://github.com/DJBen), [@jsbean](https://github.com/jsbean),
[@mxcl](https://github.com/mxcl),
[@marcblanchet](https://github.com/marcblanchet) and
[@sharplet](https://github.com/sharplet) for bug reports and pull requests!

**Implemented enhancements:**

- Conditionally conform to Combine.TopLevelDecoder
  [\#132](https://github.com/MaxDesiatov/XMLCoder/pull/132)
  ([sharplet](https://github.com/sharplet))

**Fixed bugs:**

- Value with copyright symbol © has its preceding whitespace trimmed off even
  `trimValueWhitespaces` is set to false
  [\#141](https://github.com/MaxDesiatov/XMLCoder/issues/141)
- Float vs Float64=Double not parsing 3.14
  [\#130](https://github.com/MaxDesiatov/XMLCoder/issues/130)

**Closed issues:**

- TrackPoint position parameter is ignored
  [\#125](https://github.com/MaxDesiatov/XMLCoder/issues/125)
- TCX file need an XML root node
  [\#124](https://github.com/MaxDesiatov/XMLCoder/issues/124)
- \[Swift 5.1\] Import FoundationXML rather than Foundation
  [\#121](https://github.com/MaxDesiatov/XMLCoder/issues/121)

**Merged pull requests:**

- Add whitespace trimming test with copyright symbol
  [\#147](https://github.com/MaxDesiatov/XMLCoder/pull/147)
  ([MaxDesiatov](https://github.com/MaxDesiatov))
- Fix CocoaPods issue on Azure Pipelines
  [\#146](https://github.com/MaxDesiatov/XMLCoder/pull/146)
  ([MaxDesiatov](https://github.com/MaxDesiatov))
- Fix Float32 decoding, add DoubleBox
  [\#138](https://github.com/MaxDesiatov/XMLCoder/pull/138)
  ([MaxDesiatov](https://github.com/MaxDesiatov))
- Add QuoteDecodingTest
  [\#137](https://github.com/MaxDesiatov/XMLCoder/pull/137)
  ([MaxDesiatov](https://github.com/MaxDesiatov))
- Test Root Level Attribute Encoding
  [\#134](https://github.com/MaxDesiatov/XMLCoder/pull/134)
  ([bwetherfield](https://github.com/bwetherfield))
- Add Xcode 11, Swift 5.1 support
  [\#133](https://github.com/MaxDesiatov/XMLCoder/pull/133)
  ([MaxDesiatov](https://github.com/MaxDesiatov))
- Test Decoding of Nested Arrays of Enums
  [\#126](https://github.com/MaxDesiatov/XMLCoder/pull/126)
  ([bwetherfield](https://github.com/bwetherfield))

# 0.8.0 (4 August 2019)

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

# 0.7.0 (2 July 2019)

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

# 0.6.0 (17 June 2019)

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

# 0.5.1 (2 May 2019)

Bugfix release that restores decoding of empty sequences, which became broken in
0.5.0.

**Merged pull requests:**

- Fix decoding of empty sequences
  [\#98](https://github.com/MaxDesiatov/XMLCoder/pull/98)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Rename `flatten` to `transformToBoxTree`, rename tests
  [\#97](https://github.com/MaxDesiatov/XMLCoder/pull/97)
  ([@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.5.0 (2 May 2019)

A small improvement release tagged early to resolve blocking issues in
[CoreXLSX](https://github.com/MaxDesiatov/CoreXLSX).

**Notable changes:**

- Empty value strings are no longer decoded as `nil` when a `String` is
  expected, but are decoded as empty strings, which represents the actual value.
- `trimValueWhitespaces` property was added on `XMLDecoder`, which allows
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

# 0.4.1 (12 April 2019)

A bugfix release removing unused Xcode project scheme to improve build time
for Carthage users.

**Notable changes:**

- Remove unused scheme in Xcode project ([@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.4.0 (8 April 2019)

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

- Ordered encoding: this was one of the most requested changes and it's finally
  here! 🎉 Now both keyed and unkeyed elements are encoded in the exactly same
  order that was used in original containers. This is applicable to both
  compiler-generated encoding implementations (just reorder properties or cases
  in your `CodingKeys` enum if you have it) and manually implemented `func encode(to: Encoder)`.
- Stripping namespace prefix: now if your coding key string values contain an
  XML namespace prefix (e.g. prefix `h` in `<h:td>Apples</h:td>`), you [can
  set](https://github.com/MaxDesiatov/XMLCoder/blob/3944866/README.md#stripping-namespace-prefix)
  `shouldProcessNamespaces` property to `true` on your `XMLDecoder` instance for
  the prefix to be stripped before decoding keys in your `Decodable` types.
- Previously it was possible to customize encoding with `NodeEncodingStrategy`,
  but no such type existed for decoding. A corresponding `NodeDecodingStrategy`
  type was added with `nodeDecodingStrategy` property on `XMLDecoder`.
- Thanks to the previous change, XMLCoder now provides two helper protocols that
  allow you to easily customize whether nodes are encoded and decoded as
  attributes or elements for conforming types: [`DynamicNodeEncoding` and
  `DynamicNodeDecoding`](https://github.com/MaxDesiatov/XMLCoder/blob/3944866/README.md#dynamic-node-coding).
- Previously if you needed to decode or encode an XML element with both
  attributes and values, this was impossible to do with XMLCoder. Now with the
  addition of [coding key value
  intrinsic](https://github.com/MaxDesiatov/XMLCoder/blob/3944866/README.md#coding-key-value-intrinsic),
  this is as easy as adding one coding key with a specific string raw value
  (`"value"` or empty string `""` if you already have an XML attribute named
  `"value"`).

**Closed issues:**

- Crash: Range invalid bounds in XMLStackParser.swift [\#83](https://github.com/MaxDesiatov/XMLCoder/issues/83)
- Document DynamicNodeEncoding and attributed intrinsic [\#80](https://github.com/MaxDesiatov/XMLCoder/issues/80)
- Fix nested attributed intrinsic [\#78](https://github.com/MaxDesiatov/XMLCoder/issues/78)
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
- Add `NodeDecodingStrategy`, mirroring `NodeEncodingStrategy`
  [\#45](https://github.com/MaxDesiatov/XMLCoder/pull/45)
  ([@regexident](https://github.com/regexident))

# 0.3.1 (6 February 2019)

A bugfix release that adds missing `CFBundleVersion` in generated framework's
`Info.plist` ([#72](https://github.com/MaxDesiatov/XMLCoder/issues/72) reported by
[@stonedauwg](https://github.com/stonedauwg)).

**Changes:**

- Set `CURRENT_PROJECT_VERSION` in project file ([#74](https://github.com/MaxDesiatov/XMLCoder/pull/74), [@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.3.0 (22 January 2019)

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
[@hodovani](https://github.com/hodovani) and can greatly help with attempts to
parse invalid XML, where previously only a line and column number were reported.

**Deprecations:**

`NodeEncodingStrategies` was renamed to `NodeEncodingStrategy` for consistency.
`NodeEncodingStrategies` is still available as a deprecated typealias, which
will be removed in future versions. Thanks to
[@regexident](https://github.com/regexident) for cleaning this up and providing
many more changes in this release that make `XMLCoder` better and easier to use.

**Changes:**

- Add SwiftLint and fix linter errors
  ([#35](https://github.com/MaxDesiatov/XMLCoder/pull/35),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
- Add single array element example to tests
  ([#66](https://github.com/MaxDesiatov/XMLCoder/pull/66),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
- Remove generic encode/decode functions
  ([#64](https://github.com/MaxDesiatov/XMLCoder/pull/64),
  [@hodovani](https://github.com/hodovani))
- Change internal representation to ordered array of children
  ([#55](https://github.com/MaxDesiatov/XMLCoder/pull/55),
  [@regexident](https://github.com/regexident))
- Keyed/unkeyed boxes as structs
  ([#36](https://github.com/MaxDesiatov/XMLCoder/pull/36),
  [@regexident](https://github.com/regexident))
- Add dedicated benchmarking test suite
  ([#34](https://github.com/MaxDesiatov/XMLCoder/pull/34),
  [@regexident](https://github.com/regexident))
- Add tests to increase test coverage
  ([#63](https://github.com/MaxDesiatov/XMLCoder/pull/63),
  [@hodovani](https://github.com/hodovani))
- Add tests for keyed and unkeyed int types
  ([#62](https://github.com/MaxDesiatov/XMLCoder/pull/62),
  [@hodovani](https://github.com/hodovani))
- Add test to case when error context size goes outside content size
  ([#61](https://github.com/MaxDesiatov/XMLCoder/pull/61),
  [@hodovani](https://github.com/hodovani))
- Specify Swift version for packaging, refine CI
  ([#60](https://github.com/MaxDesiatov/XMLCoder/pull/60),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
- Add test for keyed Int types
  ([#58](https://github.com/MaxDesiatov/XMLCoder/pull/58),
  [@hodovani](https://github.com/hodovani))
- Fix missing trailing semicolon in character escapings
  ([#59](https://github.com/MaxDesiatov/XMLCoder/pull/59),
  [@regexident](https://github.com/regexident))
- Increase test coverage
  ([#56](https://github.com/MaxDesiatov/XMLCoder/pull/56),
  [@hodovani](https://github.com/hodovani))
- Fix `RelationshipsTest.testDecoder` crash on failure
  ([#50](https://github.com/MaxDesiatov/XMLCoder/pull/50),
  [@regexident](https://github.com/regexident))
- Improve `XMLStackParserTests` to test against CDATA blocks
  ([#51](https://github.com/MaxDesiatov/XMLCoder/pull/51),
  [@regexident](https://github.com/regexident))
- Remove unnecessary use of `@available(…)` for `OutputFormatting.sortedKeys`
  ([#53](https://github.com/MaxDesiatov/XMLCoder/pull/53),
  [@regexident](https://github.com/regexident))
- Fix decoding of arrays with optional elements
  ([#48](https://github.com/MaxDesiatov/XMLCoder/pull/48),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
- Add Optional Error Context
  ([#46](https://github.com/MaxDesiatov/XMLCoder/pull/46),
  [@hodovani](https://github.com/hodovani))
- Install Carthage only in before_deploy on Travis
  ([#47](https://github.com/MaxDesiatov/XMLCoder/pull/47),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
- Add coding style and test coverage to README.md
  ([#44](https://github.com/MaxDesiatov/XMLCoder/pull/44),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
- Improve code coverage of auxiliary types
  ([#43](https://github.com/MaxDesiatov/XMLCoder/pull/43),
  [@regexident](https://github.com/regexident))
- Improve code coverage of box types
  ([#42](https://github.com/MaxDesiatov/XMLCoder/pull/42),
  [@regexident](https://github.com/regexident))
- Make error handling in `XMLDecoder` simpler & safer
  ([#41](https://github.com/MaxDesiatov/XMLCoder/pull/41),
  [@regexident](https://github.com/regexident))
- Unfold `guard … else` blocks to allow settingbreakpoints
  ([#39](https://github.com/MaxDesiatov/XMLCoder/pull/39),
  [@regexident](https://github.com/regexident))
- Cleanup throwing unit tests & add tests for missing values
  ([#40](https://github.com/MaxDesiatov/XMLCoder/pull/40),
  [@regexident](https://github.com/regexident))
- Let compiler synthesize Equatable conformance for \_XMLElement
  ([#33](https://github.com/MaxDesiatov/XMLCoder/pull/33),
  [@jsbean](https://github.com/jsbean))
- Apply SwiftFormat on CI runs
  ([#32](https://github.com/MaxDesiatov/XMLCoder/pull/32),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
- Fix a bug with throws on `Encodable` encoding nothing
  ([#31](https://github.com/MaxDesiatov/XMLCoder/pull/31),
  [@regexident](https://github.com/regexident))
- Clean up `XMLElement`, `ArrayBox` & `DictionaryBox`
  ([#28](https://github.com/MaxDesiatov/XMLCoder/pull/28),
  [@regexident](https://github.com/regexident))
- Extract URL coding into `URLBox` with tests
  ([#30](https://github.com/MaxDesiatov/XMLCoder/pull/30),
  [@regexident](https://github.com/regexident))
- Remove use of explicit `internal`
  ([#29](https://github.com/MaxDesiatov/XMLCoder/pull/29),
  [@regexident](https://github.com/regexident))
- Clean up coding logic, improve box naming
  ([#27](https://github.com/MaxDesiatov/XMLCoder/pull/27),
  [@regexident](https://github.com/regexident))
- Clean up `XMLStackParser`
  ([#26](https://github.com/MaxDesiatov/XMLCoder/pull/26),
  [@regexident](https://github.com/regexident))
- Overhaul internal representation, replacing `NS…` with `…Box` types
  ([#19](https://github.com/MaxDesiatov/XMLCoder/pull/19),
  [@regexident](https://github.com/regexident))
- Added benchmark to RJI test suite
  ([#20](https://github.com/MaxDesiatov/XMLCoder/pull/20),
  [@regexident](https://github.com/regexident))
- Fix generation of Jazy docs
  ([#18](https://github.com/MaxDesiatov/XMLCoder/pull/18),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
- Added unit tests for array and dictionary properties
  ([#7](https://github.com/MaxDesiatov/XMLCoder/pull/7),
  [@regexident](https://github.com/regexident))
- Moved `_XML…EncodingContainer` into their own files, matching decoder
  ([#4](https://github.com/MaxDesiatov/XMLCoder/pull/4),
  [@regexident](https://github.com/regexident))
- Convert `Sample XML` code to XCTest
  ([#1](https://github.com/MaxDesiatov/XMLCoder/pull/1),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
- Respect .sortedKeys option, add .swiftformat
  ([@qmoya](https://github.com/qmoya))
- Bring back `gem install cocoapods --pre` to Travis
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Add --verbose flag to `pod lib lint` in travis.yml
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Specify stable versions in the installation guide
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Implement Travis CI deployment of Carthage archive
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Add NodeEncodingStrategies typelias as deprecated
  ([#9](https://github.com/MaxDesiatov/XMLCoder/pull/9),
  [@MaxDesiatov](https://github.com/MaxDesiatov))
- Rename `NodeEncodingStrategies` to match other type names
  ([#8](https://github.com/MaxDesiatov/XMLCoder/pull/8),
  [@regexident](https://github.com/regexident))
- Consider node encoding strategy for values inside unkeyed containers
  ([#2](https://github.com/MaxDesiatov/XMLCoder/pull/2),
  [@regexident](https://github.com/regexident))
- Run tests with coverage, upload to codecov.io
  ([@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.2.1 (18 November 2018)

- watchOS deployment target set to 2.0 for Carthage ([@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.2.0 (18 November 2018)

- Add watchOS 2.0 deployment target ([@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.1.1 (18 November 2018)

- Set iOS deployment target to 9.0 ([@MaxDesiatov](https://github.com/MaxDesiatov))

# 0.1.0 (8 November 2018)

- Add support for decoupled, type-dependent node-encoding strategies
  ([@regexident](https://github.com/regexident))
- Add missing visibility declarations
  ([@regexident](https://github.com/regexident))
- Improve `.gitignore` and remove tracked `*.xcuserdata` files
  ([@regexident](https://github.com/regexident))
- Make `XMLEncoder.OutputFormatting.prettyPrinted` actually do something
  ([@regexident](https://github.com/regexident))
- Add tvOS deployment target to podspec ([@edc1591](https://github.com/edc1591))
- Fix Carthage command ([@salavert](https://github.com/salavert))
- Set deployment versions to allow older SDKs
  ([@Lutzifer](https://github.com/Lutzifer))
- Add Info.plist to allow Framework use in App Store Connect via Carthage
  ([@Lutzifer](https://github.com/Lutzifer))
- Set `CURRENT_PROJECT_VERSION` ([@Lutzifer](https://github.com/Lutzifer))
- Add `convertFromCapitalized` strategy, simple test
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
- Allow older iOS/tvOS deployment targets in podspec
  ([@MaxDesiatov](https://github.com/MaxDesiatov))
