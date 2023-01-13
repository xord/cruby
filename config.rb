# -*- mode: ruby; coding: utf-8 -*-


POD_VERSION = 0

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.3.tar.gz'
RUBY_SHA256 = '5ea498a35f4cd15875200a52dde42b6eb179e1264e17d78732c3a57cd1c6ab9e'

OSSL_URL    = 'https://www.openssl.org/source/openssl-3.0.7.tar.gz'
OSSL_SHA256 = '83049d042a260e696f62406ac5c08bf706fd84383f945cf21bd61e9ed95c396e'


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
