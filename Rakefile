# -*- mode: ruby; coding: utf-8 -*-


require 'open-uri'
require_relative 'config'


def read_file (path)
  open(path) {|f| f.read}
end

def write_file (path, data)
  open(path, 'w') {|f| f.write data}
end

def modify_file (path, &block)
  body     = read_file path
  modified = block.call body.dup
  write_file path, modified if modified != body
end

def download (url, path)
  puts "downloading '#{url}'..."
  write_file path, read_file(url)
end

def chdir (dir = RUBY_DIR, &block)
  Dir.chdir dir, &block
end

def xcrun (sdk, param)
  `xcrun --sdk #{sdk} #{param}`.chomp
end

def version_string (major, minor = 0, patch = 0)
  [major, minor, patch].map {|n| "%03d" % n}.join
end

def ruby25_or_higher? ()
  version_string(*CRuby.ruby_version) >= version_string(2, 5)
end


PLATFORM = (ENV['platform'] || :osx).intern
ARCHS    =
  ENV['archs'].tap {|archs| break archs.split(/[ ,]+/) if archs} ||
  ENV['arch'] .tap {|arch|  break [arch]               if arch}

NAME        = "CRuby"
LIB_NAME    = "#{NAME}_#{PLATFORM}"

ROOT_DIR     = __dir__
INC_DIR      = "#{ROOT_DIR}/include"
RUBY_DIR     = "#{ROOT_DIR}/.ruby"
OSSL_DIR     = "#{ROOT_DIR}/.openssl"
BUILD_DIR    = "#{ROOT_DIR}/.build"
OUTPUT_DIR   = "#{ROOT_DIR}/CRuby"

RUBY_CONFIGURE = "#{RUBY_DIR}/configure"
OSSL_CONFIGURE = "#{OSSL_DIR}/Configure"

NATIVE_RUBY_DIR         = "#{BUILD_DIR}/native/ruby"
NATIVE_OSSL_DIR         = "#{BUILD_DIR}/native/openssl"
NATIVE_RUBY_INSTALL_DIR = "#{BUILD_DIR}/native/ruby-install"
NATIVE_OSSL_INSTALL_DIR = "#{BUILD_DIR}/native/openssl-install"
NATIVE_RUBY_BIN         = "#{NATIVE_RUBY_INSTALL_DIR}/bin/ruby"
NATIVE_OSSL_LIB         = "#{NATIVE_OSSL_INSTALL_DIR}/libssl.a"

SYSTEM_RUBY_VER = RUBY_VERSION[/^(\d+\.\d+)\.\d+/, 1]
 EMBED_RUBY_VER = CRuby.ruby_version[0..1].join('.')
BASE_RUBY       = SYSTEM_RUBY_VER != EMBED_RUBY_VER ? NATIVE_RUBY_BIN : nil

OUTPUT_LIB_NAME = "lib#{LIB_NAME}.a"
OUTPUT_LIB_FILE = "#{OUTPUT_DIR}/#{OUTPUT_LIB_NAME}"
OUTPUT_LIB_DIR  = "#{OUTPUT_DIR}/lib"
OUTPUT_INC_DIR  = "#{OUTPUT_DIR}/include"

OUTPUT_ARCHIVE   = "#{NAME}_prebuilt-#{CRuby.version}.tar.gz"
PREBUILT_URL     = "#{GITHUB_URL}/releases/download/v#{CRuby.version}/#{OUTPUT_ARCHIVE}"
PREBUILT_ARCHIVE = "downloaded_#{OUTPUT_ARCHIVE}"

TARGETS = {
  osx: {
    macosx:          %w[x86_64],
  },
  ios: {
    iphonesimulator: %w[x86_64],
    iphoneos:        %w[arm64]
  }
}[PLATFORM]

OSSL_CONFIGURATIONS = {
  [:iphonesimulator, 'x86_64'] => 'iphoneos-cross',
  [:iphoneos,        'arm64']  => 'ios64-cross'
}

PATHS = ENV['PATH']
ENV['ac_cv_func_setpgrp_void'] = 'yes'


task :default => :build

desc "delete all temporary files"
task :clean do
  sh %( rm -rf #{OUTPUT_ARCHIVE} #{BUILD_DIR} #{OUTPUT_DIR} )
end

desc "delete all generated files"
task :clobber => :clean

desc "build"
task :build => [OUTPUT_LIB_DIR, OUTPUT_INC_DIR, OUTPUT_LIB_FILE]

directory BUILD_DIR
directory OUTPUT_DIR
directory NATIVE_RUBY_DIR
directory NATIVE_OSSL_DIR

[
  [RUBY_DIR, RUBY_URL, RUBY_CONFIGURE],
  [OSSL_DIR, OSSL_URL, OSSL_CONFIGURE]
].each do |dir, url, configure|
  archive = "#{ROOT_DIR}/#{File.basename url}"

  task :clobber do
    sh %( rm -rf #{archive} #{dir} )
  end

  directory dir

  file archive do
    download url, archive
  end

  file configure => [dir, archive] do
    sh %( tar xzf #{archive} -C #{dir} --strip=1 )
    sh %( touch #{configure} )
  end
end

file NATIVE_RUBY_BIN => [RUBY_CONFIGURE, NATIVE_RUBY_DIR, NATIVE_OSSL_LIB] do
  chdir NATIVE_RUBY_DIR do
    opts = {
      'prefix'           => NATIVE_RUBY_INSTALL_DIR,
      'with-openssl-dir' => NATIVE_OSSL_INSTALL_DIR
    }.map {|k, v| "--#{k}=#{v}"}
    sh %( #{RUBY_CONFIGURE} #{opts.join ' '} --disable-install-doc )
    sh %( make && make install )
  end
end

file NATIVE_OSSL_LIB => [OSSL_CONFIGURE, NATIVE_OSSL_DIR] do
  chdir NATIVE_OSSL_DIR do
    sh %( #{OSSL_DIR}/config --prefix=#{NATIVE_OSSL_INSTALL_DIR} )
    sh %( make && make install )
  end
end

file OUTPUT_LIB_DIR => [RUBY_CONFIGURE, OUTPUT_DIR] do
  sh %( cp -rf #{RUBY_DIR}/lib #{OUTPUT_DIR} )
  Dir.glob "#{RUBY_DIR}/ext/*/lib" do |lib|
    sh %( cp -rf #{lib}/* #{OUTPUT_LIB_DIR} ) unless Dir.glob("#{lib}/*").empty?
  end
end

file OUTPUT_INC_DIR => [RUBY_CONFIGURE, OUTPUT_DIR] do
  sh %( cp -rf #{RUBY_DIR}/include #{OUTPUT_DIR} )
  sh %( cp -rf #{INC_DIR} #{OUTPUT_DIR})
end

file OUTPUT_LIB_FILE do |t|
  sh %( lipo -create #{t.prerequisites.join ' '} -output #{OUTPUT_LIB_FILE} )
end


desc "build files for all platforms"
task :all => [:osx, :ios]

desc "build files for macOS"
task :osx do
  sh %( rake platform=osx )
end

desc "build files for iOS"
task :ios do
  sh %( rake platform=ios )
end


desc "archive built files for deploy"
task :archive => OUTPUT_ARCHIVE

file OUTPUT_ARCHIVE => :all do
  sh %( tar cvzf #{OUTPUT_ARCHIVE} #{OUTPUT_DIR.sub(ROOT_DIR + '/', '')} )
end

desc "download prebuilt binary or build all"
task :download_or_build_all => PREBUILT_ARCHIVE do
  if File.exist?(PREBUILT_ARCHIVE)
    sh %( tar xzf #{PREBUILT_ARCHIVE} )
  else
    sh %( rake all )
  end
end

file PREBUILT_ARCHIVE do
  download PREBUILT_URL, PREBUILT_ARCHIVE rescue OpenURI::HTTPError
end


TARGETS.each do |sdk, archs|
  sdk_root = xcrun sdk, '--show-sdk-path'
  cc_dir   = File.dirname xcrun(sdk, '--find cc')
  archs    = archs.select {|arch| ARCHS.include? arch} if ARCHS

  archs.each do |arch|
    build_dir = "#{BUILD_DIR}/#{sdk}_#{arch}"
    ruby_dir  = "#{build_dir}/ruby"
    ossl_dir  = "#{build_dir}/openssl"

    libruby_ver = ruby25_or_higher? ? ".#{CRuby.ruby_version.join '.'}" : ""
    libruby     = "#{ruby_dir}/libruby#{libruby_ver}-static.a"
    libossl     = "#{ossl_dir}/libssl.a"
    lib_file    = "#{build_dir}/#{OUTPUT_LIB_NAME}"

    ossl_install_dir = "#{build_dir}/openssl-install"
    ossl_config_h    = "#{ossl_install_dir}/include/openssl/opensslconf.h"

    ios = PLATFORM == :ios
    arm = arch =~ /^arm/

    namespace :ruby do
      config_h     = "#{OUTPUT_INC_DIR}/ruby/config-#{PLATFORM}_#{arch}.h"
      config_h_dir = File.dirname config_h
      makefile     = "#{ruby_dir}/Makefile"
      host         = "#{arm ? 'arm' : arch}-#{ios ? 'iphone' : 'apple'}-darwin"
      flags        = "-pipe -Os -isysroot #{sdk_root}"
      # -gdwarf-2 -no-cpp-precomp -mthumb

      if ios
        flags << " -miphoneos-version-min=10.0"

        # to skip checking macos version
        flags << " -DMAC_OS_X_VERSION_MIN_REQUIRED=MAC_OS_X_VERSION_10_5"
      end

      directory ruby_dir
      directory config_h_dir

      missing_headers = []
      if ios
        ruby_inc_dir = "#{ruby_dir}/include"
        vnode_h      = "#{ruby_inc_dir}/sys/vnode.h"
        vnode_h_dir = File.dirname vnode_h

        directory vnode_h_dir

        file vnode_h => vnode_h_dir do
          write_file vnode_h, <<-END
            #ifndef DUMMY_VNODE_H_INCLUDED
            #define DUMMY_VNODE_H_INCLUDED
            enum {VREG = 1, VDIR = 2, VLNK = 5, VT_HFS = 16, VT_CIFS = 23};
            #endif
          END
        end

        missing_headers += [vnode_h]
        flags           += " -I#{ruby_inc_dir}"
      end

      makefile_dep = [RUBY_CONFIGURE, ruby_dir, ossl_config_h, *missing_headers]
      makefile_dep << BASE_RUBY if BASE_RUBY
      file makefile => makefile_dep do
        chdir ruby_dir do
          envs = {
            'PATH'     => "#{cc_dir}:#{PATHS}",
            'CPP'      => "clang -arch #{arch} -E",
            'CC'       => "clang -arch #{arch}",
            'CXXCPP'   => "clang++ -arch #{arch} -E",
            'CXX'      => "clang++ -arch #{arch}",
            'CPPFLAGS' => "#{flags}",
            'CFLAGS'   => "#{flags} -fvisibility=hidden",
            'CXXFLAGS' => "-fvisibility-inline-hidden",
            'LDFLAGS'  => "#{flags} -L#{sdk_root}/usr/lib -lSystem"
          }.map {|k, v| "#{k}='#{v}'"}
          opts = %W[
            --host=#{host}
            --disable-shared
            --disable-dln
            --disable-jit-support
            --disable-install-doc
            --with-static-linked-ext
            --with-openssl-dir=#{ossl_install_dir}
            --without-tcl
            --without-tk
            --without-fiddle
            --without-bigdecimal
          ]
          opts << "--with-arch=#{arch}" unless arm
          opts << "--with-baseruby=#{BASE_RUBY}" if BASE_RUBY
          sh %( #{envs.join ' '} #{RUBY_CONFIGURE} #{opts.join ' '} )
        end
      end

      file config_h => [makefile, config_h_dir] do
        src = Dir.glob("#{ruby_dir}/.ext/include/**/ruby/config.h").first
        raise unless src

        # avoid crach on AdMob initialization.
        modify_file src do |s|
          %w[
            HAVE_BACKTRACE
            HAVE_SYSCALL
            HAVE___SYSCALL
          ].each do |macro|
            s = s.gsub /#define\s+#{macro}\s+1/, "#undef #{macro}"
          end
          s
        end

        sh %( cp #{src} #{config_h} )
      end

      file libruby => [makefile, config_h] do
        chdir ruby_dir do
          sh %( make )
        end
      end
    end# ruby

    namespace :openssl do
      conf = OSSL_CONFIGURATIONS[[sdk, arch]]
      envs = {
        CROSS_COMPILE: "#{cc_dir}/",
        CROSS_TOP:     "#{xcrun sdk, '--show-sdk-platform-path'}/Developer",
        CROSS_SDK:     File.basename(sdk_root)
      }.map {|k, v| "#{k}=#{v}"}

      directory ossl_dir
      directory ossl_install_dir

      file libossl => [OSSL_CONFIGURE, ossl_dir] do
        next unless conf
        chdir ossl_dir do
          opts = %W[
            --prefix=#{ossl_install_dir}
            no-shared
          ]
          sh %( #{envs.join ' '} #{OSSL_CONFIGURE} #{opts.join ' '} #{conf} )
          sh %( #{envs.join ' '} make )
        end
      end

      file ossl_config_h => [libossl, ossl_install_dir] do
        next unless conf
        chdir ossl_dir do
          sh %( make install | grep include )
        end
      end
    end# openssl

    file lib_file => [libruby, libossl] do
      extract_dir = "#{build_dir}/.#{OUTPUT_LIB_NAME}"
      excludes    = %w[dmyenc.o dmyext.o /openssl/apps/ /openssl/test/]
      extra_objs  = %w[enc ext].map {|s| "#{ruby_dir}/#{s}/#{s}init.o"}

      [ruby_dir, ossl_dir]
        .map {|dir| Dir.glob "#{dir}/**/*.a"}
        .flatten
        .reject {|path| excludes.any? {|s| path.include? s}}
        .each do |path|

        a_dir    = path[%r|#{build_dir}/(.+)\.a$|, 1]
        objs_dir = "#{extract_dir}/#{a_dir}"

        sh %( mkdir -p #{objs_dir} && cp #{path} #{objs_dir} )
        chdir objs_dir do
          sh %( ar x #{File.basename path} )
        end
      end

      chdir build_dir do
        objs =
          Dir.glob("#{extract_dir}/**/*.o")
          .reject {|path| excludes.any? {|s| path.include? s}}
        sh %( ar -crs #{lib_file} #{objs.join ' '} #{extra_objs.join ' '} )
      end
    end

    file OUTPUT_LIB_FILE => lib_file

  end# arch
end
