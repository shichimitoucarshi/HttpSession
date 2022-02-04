#
#  Be sure to run `pod spec lint Direction.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "HttpSession"
  s.version      = "1.10.0"
  s.summary      = "Http Session"
  s.description  = <<-DESC
                        TCP / IP based HTTP communication can be simplified
                   DESC

  s.homepage     = "https://github.com/keisukeYamagishi/HttpSession"
  s.license      = "MIT"
  s.author             = { "keisuke" => "jam330157@gmail.com" }
  s.source       = { :git => "https://github.com/keisukeYamagishi/HttpSession.git", :tag => "#{s.version}" }
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files  = "Source", "HttpSession/**/*.swift"
end
