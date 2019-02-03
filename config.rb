# -*- mode: ruby; coding: utf-8 -*-


POD_VERSION = 3

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.3.tar.gz'
RUBY_SHA256 = '9828d03852c37c20fa333a0264f2490f07338576734d910ee3fd538c9520846c'


module CRuby
  def self.version ()
    *heads, patch = ruby_version
    [*heads, patch * 100 + POD_VERSION].join '.'
  end

  def self.ruby_version ()
    m = RUBY_URL.match /ruby\-(\d)\.(\d)\.(\d)(?:\-\w*)?\.tar\.gz/
    raise "invalid ruby version" unless m && m.captures.size == 3
    m.captures.map &:to_i
  end
end
