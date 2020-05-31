// Copyright (c) 2020 XMLCoder contributors
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

import Danger

SwiftLint.lint(inline: true, configFile: ".swiftlint.yml", strict: true)

let danger = Danger()

print("Calling SwiftFormat...")

danger.utils.exec("swiftformat", arguments: ["."])
