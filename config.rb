# -*- mode: ruby; coding: utf-8 -*-


POD_VERSION = 0

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.3.tar.gz'
RUBY_SHA256 = '8925a95e31d8f2c81749025a52a544ea1d05dad18794e6828709268b92e55338'

OSSL_URL    = 'https://www.openssl.org/source/openssl-1.1.1k.tar.gz'
OSSL_SHA256 = '892a0875b9872acd04a9fde79b1f943075d5ea162415de3047c327df33fbaee5'


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
