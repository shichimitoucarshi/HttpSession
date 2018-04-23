#
#  Be sure to run `pod spec lint Direction.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "HttpRequest"
  s.version      = "1.0.0"
  s.summary      = "Http Request "
  s.description  = <<-DESC
                        TCP / IP based HTTP communication can be simplified
                   DESC

  s.homepage     = "https://github.com/keisukeYamagishi/HttpRequest"
  s.license      = "MIT"
  s.author             = { "keisuke" => "jam330157@gmail.com" }
  s.source       = { :git => "https://github.com/keisukeYamagishi/HttpRequest", :tag => "#{s.version}" }
  s.ios.deployment_target = '8.0'

  s.source_files  = "Source", "Source/*.swift"
end
