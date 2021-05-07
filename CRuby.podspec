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

  root = "${PODS_ROOT}/#{s.name}"

  s.requires_arc        = false
  s.source_files        = "src/*.m"
  s.libraries           = "z"
  s.preserve_paths      = "#{s.name}.xcframework"
  s.vendored_frameworks = "#{s.name}.xcframework"

  s.prepare_command = "rake download_or_build_all"
end
