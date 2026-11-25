# -*- mode: ruby -*-


POD_VERSION = 0

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/4.0/ruby-4.0.10.tar.gz'
RUBY_SHA256 = 'b53eef3371fa5d3e3b74340edcd015f06d5d8853968d4e539a5264fce41ed9f1'

OSSL_URL    = 'https://github.com/openssl/openssl/releases/download/openssl-3.6.3/openssl-3.6.3.tar.gz'
OSSL_SHA256 = '243a86649cf6f23eeb6a2ff2456e09e5d77dd9018a54d3d96b0c6bdd6ba6c7f1'

YAML_URL    = 'https://github.com/yaml/libyaml/releases/download/0.2.5/yaml-0.2.5.tar.gz'
YAML_SHA256 = 'c642ae9b75fee120b2d96c712538bd2cf283228d2337df2cf2988e3c02678ef4'


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
