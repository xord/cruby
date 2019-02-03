# -*- mode: ruby; coding: utf-8 -*-


require_relative 'config'


Pod::Spec.new do |s|
  s.name         = "CRuby"
  s.version      = CRuby.version
  s.summary      = "CRuby (MRI) Interpreter."
  s.description  = <<-END
                   CRuby (MRI) interpreter for embedding it to OSX/iOS App.
                   END
  s.license      = "MIT"
  s.source       = {:git => "https://github.com/xord/cruby"}
  s.author       = {"xord" => "xordog@gmail.com"}
  s.homepage     = "https://github.com/xord"

  s.osx.deployment_target = "10.7"
  s.ios.deployment_target = "7.0"

  root = "${PODS_ROOT}/#{s.name}"

  s.preserve_paths      = "CRuby"
  s.requires_arc        = false
  s.resource_bundles    = {"CRuby" => "CRuby/lib"}
  s.source_files        = "src/*.m"
  s.library             = "z"
  s.osx.library         = "#{s.name}_osx"
  s.ios.library         = "#{s.name}_ios"
  s.xcconfig            = {
    "HEADER_SEARCH_PATHS"  => "#{root}/CRuby/include",
    "LIBRARY_SEARCH_PATHS" => "#{root}/CRuby",
  }

  s.prepare_command = "rake download_or_build_all"
end
