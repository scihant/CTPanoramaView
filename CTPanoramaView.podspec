Pod::Spec.new do |s|
  s.name             = "CTPanoramaView"
  s.version          = "1.3"
  s.summary          = "Displays spherical or cylindrical panoramas and 360 photos with touch or motion based controls."
  s.homepage         = "https://github.com/scihant/CTPanoramaView"
  s.screenshots      = "https://cloud.githubusercontent.com/assets/3991481/23154113/ce5aa6b8-f814-11e6-9c97-4d91629733f8.gif", "https://cloud.githubusercontent.com/assets/3991481/23154919/d5f98476-f818-11e6-8c71-22011a027d96.jpg"
  s.license          = "MIT"
  s.author           = { "scihant" => "cihantek@gmail.com" }
  s.source           = { :git => "https://github.com/scihant/CTPanoramaView.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Source/*.{swift}'
  s.frameworks = 'UIKit'
end
