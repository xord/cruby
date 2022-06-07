# -*- mode: ruby; coding: utf-8 -*-


POD_VERSION = 3

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/3.1/ruby-3.1.2.tar.gz'
RUBY_SHA256 = '61843112389f02b735428b53bb64cf988ad9fb81858b8248e22e57336f24a83e'

OSSL_URL    = 'https://www.openssl.org/source/openssl-1.1.1o.tar.gz'
OSSL_SHA256 = '9384a2b0570dd80358841464677115df785edb941c71211f75076d72fe6b438f'


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
