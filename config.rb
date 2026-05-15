# -*- mode: ruby -*-


POD_VERSION = 0

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/4.0/ruby-4.0.4.tar.gz'
RUBY_SHA256 = 'f35f6edfa3dabb3f723f9d0cf1906c6512ae77f4e412ab1e68cc6e91d230fa80'

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
