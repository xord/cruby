# -*- mode: ruby -*-


POD_VERSION = 4

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/3.3/ruby-3.3.8.tar.gz'
RUBY_SHA256 = 'a0597bfdf312e010efd1effaa8d7f1d7833146fdc17950caa8158ffa3dcbfa85'

OSSL_URL    = 'https://github.com/openssl/openssl/releases/download/openssl-3.4.1/openssl-3.4.1.tar.gz'
OSSL_SHA256 = '002a2d6b30b58bf4bea46c43bdd96365aaf8daa6c428782aa4feee06da197df3'

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
