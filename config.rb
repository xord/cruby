# -*- mode: ruby -*-


POD_VERSION = 1

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/3.3/ruby-3.3.3.tar.gz'
RUBY_SHA256 = '83c05b2177ee9c335b631b29b8c077b4770166d02fa527f3a9f6a40d13f3cce2'

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
