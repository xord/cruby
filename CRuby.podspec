# -*- mode: ruby -*-

Pod::Spec.new do |s|
  s.name         = "CRuby"
  s.version      = "0.1.0"
  s.summary      = "CRuby (MRI) Interpreter."
  s.description  = <<-END
                   CRuby (MRI) interpreter for embedding it to OSX/iOS App.
                   END
  s.license      = "MIT"
  s.source       = {:git => "https://github.com/xord/cruby"}
  s.author       = {"snori" => "snori@xord.org"}
  s.homepage     = "https://github.com/xord"

  s.osx.deployment_target = "10.7"
  s.ios.deployment_target = "7.0"

  root  = "${PODS_ROOT}/#{s.name}"
  build = "#{root}/build"

  s.source_files     = "#{s.name}/**/*.{h,m}"
  s.resource_bundles = {"CRuby" => "build/lib"}
  s.xcconfig         = {"FRAMEWORK_SEARCH_PATHS" => build}

  s.preserve_paths   = "ruby", build
  s.osx.frameworks   = "#{s.name}_osx"
  s.ios.frameworks   = "#{s.name}_ios"
  s.osx.xcconfig     = {"HEADER_SEARCH_PATHS" => "#{build}/#{s.name}_osx.framework/Headers"}
  s.ios.xcconfig     = {"HEADER_SEARCH_PATHS" => "#{build}/#{s.name}_ios.framework/Headers"}

  platform = ENV['CRUBY_PLATFORM']
  archs    = ENV['CRUBY_ARCHS']
  archs    = archs ? "archs='#{archs}'" : ''
  s.prepare_command = platform ? "rake platform='#{platform}' #{archs}" : "rake all"
end
