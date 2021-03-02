#
# Be sure to run `pod lib lint KTDirectSeedingSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KTDirectSeedingSDK'
  s.version          = '0.1.4'
  s.summary          = 'A short description of KTDirectSeedingSDK.'
  s.description  = <<-DESC
                    this project provide direct seeding module
                 DESC

  s.homepage         = 'https://github.com/kestraltorah/KTDirectSeedingSDK'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'kestraltorah@163.com' => 'guowei@huami.com' }
  s.source           = { :git => 'https://github.com/kestraltorah/KTDirectSeedingSDK.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.subspec 'KTVideoService' do |video|
    video.source_files = 'KTDirectSeedingSDK/Classes/VideoService/*'
  end

  s.subspec 'KTAudioService' do |audio|
    audio.source_files = 'KTDirectSeedingSDK/Classes/AudioService/*'
  end

  s.subspec 'KTRenderService' do |render|
    render.source_files = 'KTDirectSeedingSDK/Classes/RenderService/*'
  end

end
