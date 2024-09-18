# -*- mode: ruby -*-


POD_VERSION = 5

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/3.2/ruby-3.2.2.tar.gz'
RUBY_SHA256 = '96c57558871a6748de5bc9f274e93f4b5aad06cd8f37befa0e8d94e7b8a423bc'

OSSL_URL    = 'https://github.com/openssl/openssl/releases/download/openssl-3.3.2/openssl-3.3.2.tar.gz'
OSSL_SHA256 = '2e8a40b01979afe8be0bbfb3de5dc1c6709fedb46d6c89c10da114ab5fc3d281'

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
