Pod::Spec.new do |s|
  s.name         = "DTMHeatmap"
  s.version      = "1.0"
  s.summary      = "An MKMapView overlay to visualize location data"
  s.homepage     = "https://github.com/bikram990/DTMHeatmap"
  s.license          = 'MIT'
  s.author             = { "Bryan Oltman" => "boltman@dataminr.com" }
  s.social_media_url = "http://twitter.com/moltman"
  s.module_name  = 'DTMHeatmap'
  s.osx.deployment_target = "10.12"
  s.ios.deployment_target = "10.0"
  s.source       = { :git => "https://github.com/bikram990/DTMHeatmap.git", :branch => 'master' }
  s.source_files  = 'Sources/**/*.{h,m}'
  s.requires_arc = true
end
