# -*- mode: ruby; coding: utf-8 -*-


require 'open-uri'
require_relative 'config'


def read_file (path)
  open(path) {|f| f.read}
end

def write_file (path, data)
  open(path, 'w') {|f| f.write data}
end

def chdir (dir = RUBY_DIR, &block)
  Dir.chdir dir, &block
end

def xcrun (sdk, param)
  `xcrun --sdk #{sdk} #{param}`.chomp
end


PLATFORM = (ENV['platform'] || :osx).intern
ARCHS    = ENV['archs'].tap {|o| break o.split(/ |,/) if o}

NAME        = "CRuby"
LIB_NAME    = "#{NAME}_#{PLATFORM}"

ROOT_DIR     = __dir__
INC_DIR      = "#{ROOT_DIR}/include"
RUBY_DIR     = "#{ROOT_DIR}/ruby"
BUILD_DIR    = "#{ROOT_DIR}/.build"
OUTPUT_DIR   = "#{ROOT_DIR}/CRuby"

CONFIGURE    = "#{RUBY_DIR}/configure"
MINIRUBY_DIR = "#{BUILD_DIR}/miniruby"
MINIRUBY_BIN = "#{MINIRUBY_DIR}/miniruby"

OUTPUT_LIB_NAME = "lib#{LIB_NAME}.a"
OUTPUT_LIB_FILE = "#{OUTPUT_DIR}/#{OUTPUT_LIB_NAME}"
OUTPUT_LIB_DIR  = "#{OUTPUT_DIR}/lib"
OUTPUT_INC_DIR  = "#{OUTPUT_DIR}/include"

RUBY_ARCHIVE   = "#{ROOT_DIR}/#{File.basename RUBY_URL}"
OUTPUT_ARCHIVE = "#{NAME}_prebuilt-#{CRuby.version}.tar.gz"

TARGETS = {
  osx: {
    macosx:          %w[x86_64],
  },
  ios: {
    iphonesimulator: %w[x86_64 i386],
    iphoneos:        %w[armv7 armv7s arm64]
  }
}[PLATFORM]

PATHS = ENV['PATH']
ENV['ac_cv_func_setpgrp_void'] = 'yes'


task :default => :build

desc "delete all temporary files"
task :clean do
  sh %( rm -rf #{OUTPUT_ARCHIVE} #{BUILD_DIR} #{OUTPUT_DIR} )
end

desc "delete all generated files"
task :clobber do
  sh %( rm -rf #{RUBY_ARCHIVE} #{RUBY_DIR} )
end

desc "build"
task :build => [OUTPUT_LIB_DIR, OUTPUT_INC_DIR, OUTPUT_LIB_FILE]

directory RUBY_DIR
directory BUILD_DIR
directory OUTPUT_DIR
directory MINIRUBY_DIR

file RUBY_ARCHIVE do |t|
  puts "downloading '#{t.name}'..."
  write_file RUBY_ARCHIVE, read_file(RUBY_URL)
end

file CONFIGURE => [RUBY_ARCHIVE, RUBY_DIR] do
  sh %( tar xzf #{RUBY_ARCHIVE} -C #{RUBY_DIR} --strip=1 )
  sh %( touch #{CONFIGURE} )
end

file MINIRUBY_BIN => [CONFIGURE, MINIRUBY_DIR] do
  chdir MINIRUBY_DIR do
    sh %( #{CONFIGURE} )
    sh %( make miniruby )
  end
end

file OUTPUT_LIB_DIR => [CONFIGURE, OUTPUT_DIR] do
  sh %( cp -rf #{RUBY_DIR}/lib #{OUTPUT_DIR} )
  Dir.glob "#{RUBY_DIR}/ext/*/lib" do |lib|
    sh %( cp -rf #{lib}/* #{OUTPUT_LIB_DIR} ) unless Dir.glob("#{lib}/*").empty?
  end
end

file OUTPUT_INC_DIR => [CONFIGURE, OUTPUT_DIR] do
  sh %( cp -rf #{RUBY_DIR}/include #{OUTPUT_DIR} )
  sh %( cp -rf #{INC_DIR} #{OUTPUT_DIR})
end

file OUTPUT_LIB_FILE do |t|
  sh %( lipo -create #{t.prerequisites.join ' '} -output #{OUTPUT_LIB_FILE} )
end


desc "archive built files for deploy"
task :archive => OUTPUT_ARCHIVE

file OUTPUT_ARCHIVE => :all do
  sh %( tar cvzf #{OUTPUT_ARCHIVE} #{OUTPUT_DIR.sub(ROOT_DIR + '/', '')} )
end

desc "download prebuilt binaries"
task :download

desc "download prebuilt binary or build all"
task :download_or_build_all => [:download, :all]

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


TARGETS.each do |sdk, archs|
  sdkroot = xcrun sdk, '--show-sdk-path'
  path    = xcrun(sdk, '--find cc').sub %r|/cc$|i, ''
  archs   = archs.select {|arch| ARCHS.include? arch} if ARCHS

  archs.each do |arch|
    namespace arch do
      arch_dir     = "#{BUILD_DIR}/#{sdk}_#{arch}"
      makefile     = "#{arch_dir}/Makefile"
      libruby      = "#{arch_dir}/libruby-static.a"
      lib_file     = "#{arch_dir}/#{OUTPUT_LIB_NAME}"
      config_h     = "#{OUTPUT_INC_DIR}/ruby/config-#{PLATFORM}_#{arch}.h"
      config_h_dir = File.dirname config_h
      host         = "#{arch =~ /^arm/ ? 'arm' : arch}-apple-darwin"
      flags        = "-pipe -Os -isysroot #{sdkroot}"
      flags << " -miphoneos-version-min=7.0" if PLATFORM == :ios
      # -gdwarf-2 -no-cpp-precomp -mthumb

      directory arch_dir
      directory config_h_dir

      missing_headers = []
      if PLATFORM == :ios
        arch_inc_dir = "#{arch_dir}/include"
        vnode_h      = "#{arch_inc_dir}/sys/vnode.h"
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
        flags           += " -I#{arch_inc_dir}"
      end

      file makefile => [CONFIGURE, MINIRUBY_BIN, arch_dir, *missing_headers] do
        chdir arch_dir do
          ENV['PATH']     = "#{path}:#{PATHS}"
          ENV['CPP']      = "clang -arch #{arch} -E"
          ENV['CC']       = "clang -arch #{arch}"
          ENV['CXXCPP']   = "clang++ -arch #{arch} -E"
          ENV['CXX']      = "clang++ -arch #{arch}"
          ENV['CPPFLAGS'] = "#{flags}"
          ENV['CFLAGS']   = "#{flags} -fvisibility=hidden"
          ENV['CXXFLAGS'] = "-fvisibility-inline-hidden"
          ENV['LDFLAGS']  = "#{flags} -L#{sdkroot}/usr/lib -lSystem"
          opts            = %w[
            --disable-shared
            --with-static-linked-ext
            --without-tcl
            --without-tk
            --without-fiddle
            --without-bigdecimal
            --disable-install-doc
          ]
          opts << "--with-arch=#{arch}" unless arch =~ /^arm/
          sh %( #{CONFIGURE} --host=#{host} #{opts.join ' '} )
        end
      end

      file config_h => [makefile, config_h_dir] do
        src = Dir.glob "#{arch_dir}/.ext/include/**/ruby/config.h"
        raise unless src.size == 1
        sh %( cp #{src.first} #{config_h} )
      end

      file libruby => makefile do
        chdir arch_dir do
          sh %( make miniruby )
          sh %( cp #{MINIRUBY_BIN} miniruby )
          sh %( make )
        end
      end

      file lib_file => [config_h, libruby] do
        chdir arch_dir do
          Dir.glob("#{arch_dir}/**/*.a") do |path|
            extract_dir = '.' + OUTPUT_LIB_NAME
            libfile_dir = path[%r|#{arch_dir}/(.+)\.a$|, 1]
            objs_dir    = "#{extract_dir}/#{libfile_dir}"

            sh %( mkdir -p #{objs_dir} && cp #{path} #{objs_dir} )
            chdir objs_dir do
              sh %( ar x #{File.basename path} )
            end
          end

          objs = Dir.glob "**/*.o"
          sh %( ar -crs #{lib_file} #{objs.join ' '} )
        end
      end

      file OUTPUT_LIB_FILE => lib_file

    end# arch
  end
end
