# -*- mode: ruby -*-


POD_VERSION = 0

GITHUB_URL  = "https://github.com/xord/cruby"

RUBY_URL    = 'https://cache.ruby-lang.org/pub/ruby/3.3/ruby-3.3.6.tar.gz'
RUBY_SHA256 = '8dc48fffaf270f86f1019053f28e51e4da4cce32a36760a0603a9aee67d7fd8d'

OSSL_URL    = 'https://github.com/openssl/openssl/releases/download/openssl-3.4.0/openssl-3.4.0.tar.gz'
OSSL_SHA256 = 'e15dda82fe2fe8139dc2ac21a36d4ca01d5313c75f99f46c4e8a27709b7294bf'

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
