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

  root = "$(PODS_ROOT)/#{s.name}"

  s.source_files     = "#{s.name}/**/*.{h,m}"
  s.resource_bundles = {"CRuby" => "ruby/lib"}
  s.xcconfig         = {"FRAMEWORK_SEARCH_PATHS" => root}

  s.preserve_paths   = "#{s.name}_osx.framework", "#{s.name}_ios.framework", "ruby"
  s.osx.frameworks   = "#{s.name}_osx"
  s.ios.frameworks   = "#{s.name}_ios"
  s.osx.xcconfig     = {"HEADER_SEARCH_PATHS" => "#{root}/#{s.name}_osx.framework/Headers"}
  s.ios.xcconfig     = {"HEADER_SEARCH_PATHS" => "#{root}/#{s.name}_ios.framework/Headers"}

  s.prepare_command = "rake all"
end
