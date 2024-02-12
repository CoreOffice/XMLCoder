Pod::Spec.new do |s|
  s.name          = "XMLCoder"
  s.version       = "0.17.1"
  s.summary       = "XMLEncoder & XMLDecoder using the Codable protocol in Swift"
  s.description   = "XMLCoder allows Swift Codable-conforming objects to be translated to and from XML"
  s.homepage      = "https://github.com/CoreOffice/XMLCoder"
  s.license       = { :type => "MIT", :file => "LICENSE" }
  s.authors        = {
    "Shawn Moore" => "sm5@me.com",
    "Max Desiatov" => "max@desiatov.com",
    "Joannis Orlandos" => "joannis@orlandos.nl"
  }
  s.watchos.deployment_target = "2.0"
  s.ios.deployment_target = "9.0"
  s.tvos.deployment_target = "9.0"
  s.osx.deployment_target = "10.11"
  s.swift_versions = ["5.1"]
  s.source        = { :git => "https://github.com/CoreOffice/XMLCoder.git", :tag => s.version.to_s }
  s.source_files  = "Sources/XMLCoder/**/*.swift"
  s.requires_arc  = true
end
