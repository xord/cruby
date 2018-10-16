# -*- mode: ruby; coding: utf-8 -*-


RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.0.tar.gz'
RUBY_SHA256 = 'ba5ba60e5f1aa21b4ef8e9bf35b9ddb57286cb546aac4b5a28c71f459467e507'

POD_VERSION = 0


module CRuby
  def self.version ()
    major, minor = ruby_version
    [major, minor, POD_VERSION].join '.'
  end

  def self.ruby_version ()
    m = RUBY_URL.match /ruby\-(\d)\.(\d)\.(\d)\.tar\.gz/
    raise "invalid ruby version" unless m && m.captures.size == 3
    m.captures.map &:to_i
  end
end
