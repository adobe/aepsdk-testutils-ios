Pod::Spec.new do |s|
  s.name             = "AEPTestUtils"
  s.version          = "1.0.0-beta"
  s.summary          = "Experience Platform test utilities for Adobe Experience Platform Mobile SDK. Written and maintained by Adobe."

  s.description      = <<-DESC
                       The Experience Platform test utilities enable easier testing of Adobe Experience Platform Mobile SDKs.
                       DESC

  s.homepage         = "https://github.com/adobe/aepsdk-testutils-ios.git"
  s.license          = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  s.author           = "Adobe Experience Platform SDK Team"
  s.source           = { :git => "https://github.com/adobe/aepsdk-testutils-ios.git", :tag => s.version.to_s }
  
  s.ios.deployment_target = '11.0'
  s.tvos.deployment_target = '11.0'

  s.swift_version = '5.1'

  s.pod_target_xcconfig = { 'BUILD_LIBRARY_FOR_DISTRIBUTION' => 'YES' }
  s.dependency 'AEPCore', '>= 4.0.0'
  s.dependency 'AEPServices', '>= 4.0.0'

  s.source_files = 'Sources/**/*.swift'
  s.frameworks   = 'XCTest'
end
