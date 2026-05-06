# -*- mode: ruby -*-


POD_VERSION = 1

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/4.0/ruby-4.0.3.tar.gz'
RUBY_SHA256 = '77964acc370d5c8375b9502e5ba6c13c03ef91ab9eb9f521c84fb42b9c9a6b0f'

OSSL_URL    = 'https://github.com/openssl/openssl/releases/download/openssl-3.6.2/openssl-3.6.2.tar.gz'
OSSL_SHA256 = 'aaf51a1fe064384f811daeaeb4ec4dce7340ec8bd893027eee676af31e83a04f'

YAML_URL    = 'https://github.com/yaml/libyaml/releases/download/0.2.5/yaml-0.2.5.tar.gz'


module CRuby
  def self.version ()
    *heads, patch = ruby_version
    [*heads, patch * 100 + POD_VERSION].join '.'
  end

  def self.ruby_version ()
    m = RUBY_URL.match /ruby\-(\d)\.(\d)\.(\d+)(?:\-\w*)?\.tar\.gz/
    raise "invalid ruby version" unless m && m.captures.size == 3
    m.captures.map &:to_i
  end
end
