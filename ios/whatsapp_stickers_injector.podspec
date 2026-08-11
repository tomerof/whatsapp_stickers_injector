#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint whatsapp_stickers_injector.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'whatsapp_stickers_injector'
  s.version          = '1.1.4'
  s.summary          = 'WhatsApp Stickers plugin for Flutter.'
  s.description      = <<-DESC
WhatsApp Stickers plugin for Flutter.
                       DESC
  s.homepage         = 'https://github.com/tomerof/whatsapp_stickers_injector'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'anderscheow' => 'anderscheow94@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'whatsapp_stickers_injector/Sources/whatsapp_stickers_injector/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'SDWebImageWebPCoder'
  s.platform = :ios, '13.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
