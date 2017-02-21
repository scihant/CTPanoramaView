Pod::Spec.new do |s|
  s.name             = "CTPanoramaView"
  s.version          = "1.0"
  s.summary          = "Displays spherical 360 photos or panoramic images."
  s.homepage         = "https://github.com/scihant/CTPanoramaView"
  s.screenshots      = "https://s3.amazonaws.com/tek-files/static.png", "https://s3.amazonaws.com/tek-files/dynamic_rect.gif", "https://s3.amazonaws.com/tek-files/dynamic_circle.gif"
  s.license          = "MIT"
  s.author           = { "scihant" => "cihantek@gmail.com" }
  s.source           = { :git => "https://github.com/scihant/CTPanoramaView.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Source/*.{swift}'
  s.frameworks = 'UIKit'
end
