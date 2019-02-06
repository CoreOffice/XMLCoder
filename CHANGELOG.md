#  0.3.1 (February 6, 2019)

A bugfix release that adds missing `CFBundleVersion` in generated framework's 
`Info.plist` ([#72](https://github.com/MaxDesiatov/XMLCoder/issues/72) reported by 
[@stonedauwg](https://github.com/stonedauwg)).

## Changes

* Set `CURRENT_PROJECT_VERSION` in project file ([#74](https://github.com/MaxDesiatov/XMLCoder/pull/74), [@MaxDesiatov](https://github.com/MaxDesiatov))

#  0.3.0 (January 22, 2019)

A maintenance release focused on fixing bugs, improving error reporting and
overall internal architecture of the library. For this release we've started
tracking test coverage and were able to increase it from 11.8% to 75.6%. 🎉
Thanks to [@hodovani](https://github.com/hodovani) and
[@regexident](https://github.com/regexident) for their work on improving test
coverage in this release.

## Additions

You can now set `errorContextLength: UInt` property on `XMLDecoder` instance,
which will make it add a snippet of XML of at most this length from parser state
when a parsing error occurs. This change was provided by
[@hodovani](https://github.com/hodovani) and  can greatly help with attempts to
parse invalid XML, where previously only a line and column number were reported.

## Deprecations

`NodeEncodingStrategies` was renamed to `NodeEncodingStrategy` for consistency.
`NodeEncodingStrategies` is still available as a deprecated typealias, which
will be removed in future versions. Thanks to
[@regexident](https://github.com/regexident) for cleaning this up and providing
many more changes in this release that make `XMLCoder` better and easier to use.

## Changes

* Add SwiftLint and fix linter errors ([#35](https://github.com/MaxDesiatov/XMLCoder/pull/35), [@MaxDesiatov](https://github.com/MaxDesiatov))
* Add single array element example to tests ([#66](https://github.com/MaxDesiatov/XMLCoder/pull/66), [@MaxDesiatov](https://github.com/MaxDesiatov))
* Remove generic encode/decode functions ([#64](https://github.com/MaxDesiatov/XMLCoder/pull/64), [@hodovani](https://github.com/hodovani))
* Change internal representation to ordered array of children ([#55](https://github.com/MaxDesiatov/XMLCoder/pull/55), [@regexident](https://github.com/regexident))
* Keyed/unkeyed boxes as structs ([#36](https://github.com/MaxDesiatov/XMLCoder/pull/36), [@regexident](https://github.com/regexident))
* Add dedicated benchmarking test suite ([#34](https://github.com/MaxDesiatov/XMLCoder/pull/34), [@regexident](https://github.com/regexident))
* Add tests to increase test coverage ([#63](https://github.com/MaxDesiatov/XMLCoder/pull/63), [@hodovani](https://github.com/hodovani))
* Add tests for keyed and unkeyed int types ([#62](https://github.com/MaxDesiatov/XMLCoder/pull/62), [@hodovani](https://github.com/hodovani))
* Add test to case when error context size goes outside content size ([#61](https://github.com/MaxDesiatov/XMLCoder/pull/61), [@hodovani](https://github.com/hodovani))
* Specify Swift version for packaging, refine CI ([#60](https://github.com/MaxDesiatov/XMLCoder/pull/60), [@MaxDesiatov](https://github.com/MaxDesiatov))
* Add test for keyed Int types ([#58](https://github.com/MaxDesiatov/XMLCoder/pull/58), [@hodovani](https://github.com/hodovani))
* Fix missing trailing semicolon in character escapings ([#59](https://github.com/MaxDesiatov/XMLCoder/pull/59), [@regexident](https://github.com/regexident))
* Increase test coverage ([#56](https://github.com/MaxDesiatov/XMLCoder/pull/56), [@hodovani](https://github.com/hodovani))
* Fix `RelationshipsTest.testDecoder` crash on failure ([#50](https://github.com/MaxDesiatov/XMLCoder/pull/50), [@regexident](https://github.com/regexident))
* Improve `XMLStackParserTests` to test against CDATA blocks ([#51](https://github.com/MaxDesiatov/XMLCoder/pull/51), [@regexident](https://github.com/regexident))
* Remove unnecessary use of `@available(…)` for `OutputFormatting.sortedKeys` ([#53](https://github.com/MaxDesiatov/XMLCoder/pull/53), [@regexident](https://github.com/regexident))
* Fix decoding of arrays with optional elements ([#48](https://github.com/MaxDesiatov/XMLCoder/pull/48), [@MaxDesiatov](https://github.com/MaxDesiatov))
* Add Optional Error Context ([#46](https://github.com/MaxDesiatov/XMLCoder/pull/46), [@hodovani](https://github.com/hodovani))
* Install Carthage only in before_deploy on Travis ([#47](https://github.com/MaxDesiatov/XMLCoder/pull/47), [@MaxDesiatov](https://github.com/MaxDesiatov))
* Add coding style and test coverage to README.md ([#44](https://github.com/MaxDesiatov/XMLCoder/pull/44), [@MaxDesiatov](https://github.com/MaxDesiatov))
* Improve code coverage of auxiliary types ([#43](https://github.com/MaxDesiatov/XMLCoder/pull/43), [@regexident](https://github.com/regexident))
* Improve code coverage of box types ([#42](https://github.com/MaxDesiatov/XMLCoder/pull/42), [@regexident](https://github.com/regexident))
* Make error handling in `XMLDecoder` simpler & safer ([#41](https://github.com/MaxDesiatov/XMLCoder/pull/41), [@regexident](https://github.com/regexident))
* Unfold `guard … else` blocks to allow settingbreakpoints ([#39](https://github.com/MaxDesiatov/XMLCoder/pull/39), [@regexident](https://github.com/regexident))
* Cleanup throwing unit tests & add tests for missing values ([#40](https://github.com/MaxDesiatov/XMLCoder/pull/40), [@regexident](https://github.com/regexident))
* Let compiler synthesize Equatable conformance for _XMLElement ([#33](https://github.com/MaxDesiatov/XMLCoder/pull/33), [@jsbean](https://github.com/jsbean))
* Apply SwiftFormat on CI runs ([#32](https://github.com/MaxDesiatov/XMLCoder/pull/32), [@MaxDesiatov](https://github.com/MaxDesiatov))
* Fix a bug with throws on `Encodable` encoding nothing ([#31](https://github.com/MaxDesiatov/XMLCoder/pull/31), [@regexident](https://github.com/regexident))
* Clean up `XMLElement`, `ArrayBox` & `DictionaryBox` ([#28](https://github.com/MaxDesiatov/XMLCoder/pull/28), [@regexident](https://github.com/regexident))
* Extract URL coding into `URLBox` with tests ([#30](https://github.com/MaxDesiatov/XMLCoder/pull/30), [@regexident](https://github.com/regexident))
* Remove use of explicit `internal` ([#29](https://github.com/MaxDesiatov/XMLCoder/pull/29), [@regexident](https://github.com/regexident))
* Clean up coding logic, improve box naming ([#27](https://github.com/MaxDesiatov/XMLCoder/pull/27), [@regexident](https://github.com/regexident))
* Clean up `XMLStackParser` ([#26](https://github.com/MaxDesiatov/XMLCoder/pull/26), [@regexident](https://github.com/regexident))
* Overhaul internal representation, replacing `NS…` with `…Box` types ([#19](https://github.com/MaxDesiatov/XMLCoder/pull/19), [@regexident](https://github.com/regexident))
* Added benchmark to RJI test suite ([#20](https://github.com/MaxDesiatov/XMLCoder/pull/20), [@regexident](https://github.com/regexident))
* Fix generation of Jazy docs ([#18](https://github.com/MaxDesiatov/XMLCoder/pull/18), [@MaxDesiatov](https://github.com/MaxDesiatov))
* Added unit tests for array and dictionary properties ([#7](https://github.com/MaxDesiatov/XMLCoder/pull/7), [@regexident](https://github.com/regexident))
* Moved `_XML…EncodingContainer` into their own files, matching decoder ([#4](https://github.com/MaxDesiatov/XMLCoder/pull/4), [@regexident](https://github.com/regexident))
* Convert `Sample XML` code to XCTest ([#1](https://github.com/MaxDesiatov/XMLCoder/pull/1), [@MaxDesiatov](https://github.com/MaxDesiatov))
* Respect .sortedKeys option, add .swiftformat ([@qmoya](https://github.com/qmoya))
* Bring back `gem install cocoapods --pre` to Travis ([@MaxDesiatov](https://github.com/MaxDesiatov))
* Add --verbose flag to `pod lib lint` in travis.yml ([@MaxDesiatov](https://github.com/MaxDesiatov))
* Specify stable versions in the installation guide ([@MaxDesiatov](https://github.com/MaxDesiatov))
* Implement Travis CI deployment of Carthage archive ([@MaxDesiatov](https://github.com/MaxDesiatov))
* Add NodeEncodingStrategies typelias as deprecated ([#9](https://github.com/MaxDesiatov/XMLCoder/pull/9), [@MaxDesiatov](https://github.com/MaxDesiatov))
* Rename `NodeEncodingStrategies` to match other type names ([#8](https://github.com/MaxDesiatov/XMLCoder/pull/8), [@regexident](https://github.com/regexident))
* Consider node encoding strategy for values inside unkeyed containers ([#2](https://github.com/MaxDesiatov/XMLCoder/pull/2), [@regexident](https://github.com/regexident))
* Run tests with coverage, upload to codecov.io ([@MaxDesiatov](https://github.com/MaxDesiatov))

#  0.2.1 (November 18, 2018)

* watchOS deployment target set to 2.0 for Carthage ([@MaxDesiatov](https://github.com/MaxDesiatov))

#  0.2.0 (November 18, 2018)

* Add watchOS 2.0 deployment target ([@MaxDesiatov](https://github.com/MaxDesiatov))

#  0.1.1 (November 18, 2018)

* Set iOS deployment target to 9.0 ([@MaxDesiatov](https://github.com/MaxDesiatov))

#  0.1.0 (November 8, 2018)

* Add support for decoupled, type-dependent node-encoding strategies ([@regexident](https://github.com/regexident))
* Add missing visibility declarations ([@regexident](https://github.com/regexident))
* Improve `.gitignore` and remove tracked `*.xcuserdata` files ([@regexident](https://github.com/regexident))
* Make `XMLEncoder.OutputFormatting.prettyPrinted` actually do something ([@regexident](https://github.com/regexident))
* Add tvOS deployment target to podspec ([@edc1591](https://github.com/edc1591))
* Fix Carthage command ([@salavert](https://github.com/salavert))
* Set deployment versions to allow older SDKs ([@Lutzifer](https://github.com/Lutzifer))
* Add Info.plist to allow Framework use in App Store Connect via Carthage ([@Lutzifer](https://github.com/Lutzifer))
* Set `CURRENT_PROJECT_VERSION`  ([@Lutzifer](https://github.com/Lutzifer))
* Add `convertFromCapitalized` strategy, simple test ([@MaxDesiatov](https://github.com/MaxDesiatov))
* Allow older iOS/tvOS deployment targets in podspec ([@MaxDesiatov](https://github.com/MaxDesiatov))
