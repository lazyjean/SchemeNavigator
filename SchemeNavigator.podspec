#
# Be sure to run `pod lib lint SchemeNavigator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SchemeNavigator'
  s.version          = '0.3.4'
  s.summary          = '简单的路由框架'
  s.description      = <<-DESC
简单的路由框架,方便实现后台下发一个跳转地址，app端实现页面的跳转
                       DESC

  s.homepage         = 'https://github.com/lazyjean/SchemeNavigator'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liuzhen' => 'lazy66@me.com' }
s.source           = { :git => 'https://github.com/lazyjean/SchemeNavigator.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'SchemeNavigator/**/*'
  s.public_header_files = 'SchemeNavigator/**/*.h'
end
