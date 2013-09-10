Pod::Spec.new do |s|
  s.name         = "WEPopover"
  s.version      = "0.1.0"
  s.summary      = "Generic popover implementation for iOS which uses and extends the UIPopoverController's API to allow customized look & feel."
  s.homepage     = "http://EXAMPLE/WEPopover"
  s.license      = 'MIT'
  s.authors      = { "Werner Altewischer" => "http://www.werner-it.com/", 
                     "Minh Tu Le" => "minhtu@labgoo.com" }
  s.source       = { :git => "https://github.com/Labgoo/WEPopover.git",
                     :tag => "v#{s.version}" }
  s.platform     = :ios, "5.0"
  s.source_files = 'WEPopover/**/*.{h,m}'
  s.resources    = "WEPopover/images/*.png"
  s.framework    = 'QuartzCore'
  s.requires_arc = true
end
