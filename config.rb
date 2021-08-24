# -*- mode: ruby; coding: utf-8 -*-


POD_VERSION = 2

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/2.7/ruby-2.7.4.tar.gz'
RUBY_SHA256 = '3043099089608859fc8cce7f9fdccaa1f53a462457e3838ec3b25a7d609fbc5b'

OSSL_URL    = 'https://www.openssl.org/source/openssl-1.1.1l.tar.gz'
OSSL_SHA256 = '0b7a3e5e59c34827fe0c3a74b7ec8baef302b98fa80088d7f9153aa16fa76bd1'


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
