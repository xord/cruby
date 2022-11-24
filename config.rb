# -*- mode: ruby; coding: utf-8 -*-


POD_VERSION = 0

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.3.tar.gz'
RUBY_SHA256 = '5ea498a35f4cd15875200a52dde42b6eb179e1264e17d78732c3a57cd1c6ab9e'

OSSL_URL    = 'https://www.openssl.org/source/openssl-1.1.1s.tar.gz'
OSSL_SHA256 = 'c5ac01e760ee6ff0dab61d6b2bbd30146724d063eb322180c6f18a6f74e4b6aa'


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
