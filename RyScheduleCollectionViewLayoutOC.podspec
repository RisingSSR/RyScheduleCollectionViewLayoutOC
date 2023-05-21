#
# Be sure to run `pod lib lint RyScheduleCollectionViewLayoutOC.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RyScheduleCollectionViewLayoutOC'
  s.version          = '0.1.0'
  s.summary          = '单个封装ScheduleCollectionViewLayout的OC版本'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
不同的头组
包括有：
- ScheduleCollectionViewLayout (class)
- ScheduleCollectionViewLayoutDataSource (protocol)
- ScheduleCollectionViewDataSource (protocol)
- ScheduleCollectionViewLayoutAttributes(class)
                       DESC

  s.homepage         = 'https://github.com/RisingSSR/RyScheduleCollectionViewLayoutOC'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'RisingSSR' => '2769119954@qq.com' }
  s.source           = { :git => 'https://github.com/RisingSSR/RyScheduleCollectionViewLayoutOC.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'RyScheduleCollectionViewLayoutOC/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RyScheduleCollectionViewLayoutOC' => ['RyScheduleCollectionViewLayoutOC/Assets/*.png']
  # }

  s.public_header_files = 'RyScheduleCollectionViewLayoutOC/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'RyScheduleCourseOC'
end
