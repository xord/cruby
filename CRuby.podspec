# -*- mode: ruby; coding: utf-8 -*-


require_relative 'config'


Pod::Spec.new do |s|
  s.name        = "CRuby"
  s.version     = CRuby.version
  s.license     = "MIT"
  s.source      = {:git => "https://github.com/xord/cruby"}
  s.author      = {"xord" => "xordog@gmail.com"}
  s.homepage    = "https://github.com/xord"
  s.summary     = "CRuby (MRI) Interpreter."
  s.description = <<~END
    CRuby (MRI) interpreter for embedding it to OSX/iOS App.
  END

  s.osx.deployment_target = "10.7"
  s.ios.deployment_target = "10.0"

  root = "${PODS_ROOT}/CRuby"

  s.requires_arc        = false
  s.resource_bundles    = {"CRuby" => "CRuby/lib"}
  s.source_files        = "src/*.m"
  s.libraries           = "ruby-static", "z"
  s.preserve_paths      = "CRuby"
  s.vendored_frameworks = "CRuby/CRuby.xcframework"
  s.xcconfig            = {"HEADER_SEARCH_PATHS" => "#{root}/CRuby/include"}

  s.prepare_command = "rake download_or_build"
end
