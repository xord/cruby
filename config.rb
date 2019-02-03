# -*- mode: ruby; coding: utf-8 -*-


POD_VERSION = 0

GITHUB_URL  = "https://github.com/xord/cruby"

{
  '2.6' => {
    url:    'https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.1.tar.gz',
    sha256: '17024fb7bb203d9cf7a5a42c78ff6ce77140f9d083676044a7db67f1e5191cb8'
  },
  '2.5' => {
    url:    'https://cache.ruby-lang.org/pub/ruby/2.5/ruby-2.5.3.tar.gz',
    sha256: '9828d03852c37c20fa333a0264f2490f07338576734d910ee3fd538c9520846c'
  },
  '2.4' => {
    url:    'https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.5.tar.gz',
    sha256: '6737741ae6ffa61174c8a3dcdd8ba92bc38827827ab1d7ea1ec78bc3cefc5198'
  },
  '2.3' => {
    url:    'https://cache.ruby-lang.org/pub/ruby/2.3/ruby-2.3.8.tar.gz',
    sha256: 'b5016d61440e939045d4e22979e04708ed6c8e1c52e7edb2553cf40b73c59abf'
  }
}['2.6'].tap {|ruby|
  RUBY_URL    = ruby[:url]
  RUBY_SHA256 = ruby[:sha256]
}


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
