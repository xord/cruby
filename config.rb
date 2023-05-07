# -*- mode: ruby -*-


POD_VERSION = 2

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/3.2/ruby-3.2.2.tar.gz'
RUBY_SHA256 = '96c57558871a6748de5bc9f274e93f4b5aad06cd8f37befa0e8d94e7b8a423bc'

OSSL_URL    = 'https://www.openssl.org/source/openssl-3.0.8.tar.gz'
OSSL_SHA256 = '6c13d2bf38fdf31eac3ce2a347073673f5d63263398f1f69d0df4a41253e4b3e'

YAML_URL    = 'https://github.com/yaml/libyaml/releases/download/0.2.5/yaml-0.2.5.tar.gz'


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
