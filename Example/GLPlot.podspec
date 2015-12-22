#
# Be sure to run `pod lib lint NSObjectSwizzle.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = "GLPlot"
s.version          = "0.1.0"
s.summary          = "Objective-C, OpenGL powered plotting library"
s.description      = "Missing OpneGL & GLKit powered plotting library for iOS"

s.homepage         = "https://github.com/lukaszmargielewski/GLPlot"
# s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
#s.license          = 'MIT'
s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
LICENSE
}

s.author           = { "Lukasz Margielewski" => "lukasz.margielewski@gmail.com" }
s.source           = { :git => "https://github.com/lukaszmargielewski/GLPlot.git", :tag => "#{s.version}" }
# s.social_media_url = 'https://twitter.com/lukmarg'

s.platform     = :ios, '7.0'
s.requires_arc = true
s.source_files = 'GLPlot/*'

end