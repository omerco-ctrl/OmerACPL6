Pod::Spec.new do |s|
  s.name             = 'OmerACPL6'
  s.version          = "1.0.2"
  s.summary          = 'Appcharge Checkout SDK'
  s.description      = <<-DESC
A lightweight static binary SDK for Appcharge Checkout, providing
seamless integration with Appcharge payment flows.
  DESC

  s.homepage         = 'https://github.com/omerco-ctrl/OmerACPL6'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }

  # Multiple authors
  s.author           = { 'App Charge' => 'omer.co@appcharge.com' }

  s.platform           = :ios, '13.0'
  s.swift_versions     = ['5.5', '5.9', '6.0', '6.1']
  s.cocoapods_version  = '>= 1.16.0'

  s.source             = {
    :git => 'https://github.com/omerco-ctrl/OmerACPL6.git',
    :tag => s.version.to_s
  }

  s.vendored_frameworks = "ACPaymentLinks.xcframework"
  s.preserve_paths      = "ACPaymentLinks.xcframework"
  s.static_framework     = true
end

