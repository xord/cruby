# -*- mode: ruby; coding: utf-8 -*-


POD_VERSION = 2

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/3.0/ruby-3.0.1.tar.gz'
RUBY_SHA256 = '369825db2199f6aeef16b408df6a04ebaddb664fb9af0ec8c686b0ce7ab77727'

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
