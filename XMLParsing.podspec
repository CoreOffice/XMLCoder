Pod::Spec.new do |s|
  s.name         = "XMLParsing"
  s.version      = "0.0.3"
  s.summary      = "XMLEncoder & XMLDecoder using the Codable protocol in Swift 4"
  s.description  = "XMLParsing allows Swift 4 Codable-conforming objects to be translated to and from XML"
  s.homepage     = "https://github.com/ShawnMoore/XMLParsing"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Shawn Moore" => "sm5@me.com" }
  s.ios.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"
  s.source       = { :git => "https://github.com/ShawnMoore/XMLParsing.git", :tag => s.version.to_s }
  s.source_files = "Sources/XMLParsing/**/*.swift"
  s.requires_arc = true
end
