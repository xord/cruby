# -*- coding: utf-8; mode: ruby -*-


require 'open-uri'


def read_file (path)
  open(path) {|f| f.read}
end

def write_file (path, data)
  open(path, 'w') {|f| f.write data}
end

def chdir (dir = RUBY_DIR, &block)
  Dir.chdir dir, &block
end

def make_symlink (base_dir, from, to)
  from, to = [from, to].map {|s| s.sub "#{base_dir}/", ''}
  chdir base_dir do
    sh %( ln -s #{from} #{to} )
  end
end

def xcrun (sdk, param)
  `xcrun --sdk #{sdk} #{param}`.chomp
end


PLATFORM = (ENV['platform'] || :osx).intern
ARCHS    = ENV['archs'].tap {|o| break o.split(/ |,/) if o}
ROOT_DIR = File.expand_path "..", __FILE__

NAME     = "CRuby"
LIB_NAME = "#{NAME}_#{PLATFORM}"

TARGETS  = {
  osx: {
    macosx:          {archs: %w[i386 x86_64]},
  },
  ios: {
    iphonesimulator: {archs: %w[i386 x86_64]},
    iphoneos:        {archs: %w[armv7 armv7s arm64]}
  }
}[PLATFORM]

RUBY_URL     = "http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.1.tar.gz"
RUBY_SHA256  = '5a4de38068eca8919cb087d338c0c2e3d72c9382c804fb27ab746e6c7819ab28'
RUBY_ARCHIVE = File.basename RUBY_URL
RUBY_DIR     = "#{ROOT_DIR}/ruby"

PATHS         = ENV['PATH']
ENV['CPP']    = "clang -E"
ENV['CC']     = "clang -nostdlib"
ENV['CXXCPP'] = "clang++ -E"
ENV['CXX']    = "clang++"
ENV['ac_cv_func_setpgrp_void'] = 'yes'


$archs = {}


task :default => :make

task :make => 'framework:make'

task :clean => %w[ruby framework].map {|s| "#{s}:clean"}

task :all do
  sh %( rake platform=osx )
  sh %( rake platform=ios )
end


namespace :ruby do

  lib_name = "#{LIB_NAME}.a"
  lib_all  = "#{ROOT_DIR}/#{lib_name}"

  configure = "#{RUBY_DIR}/configure"
  lib_dir   = "#{RUBY_DIR}/.lib"

  task :clean do
    sh %( rm -rf #{RUBY_ARCHIVE} #{RUBY_DIR} #{lib_all} )
  end

  file RUBY_ARCHIVE do |t|
    puts "downloading '#{t.name}'..."
    write_file RUBY_ARCHIVE, read_file(RUBY_URL)
  end

  directory RUBY_DIR

  file configure => [RUBY_ARCHIVE, RUBY_DIR] do
    sh %( tar xvzf #{RUBY_ARCHIVE} -C #{RUBY_DIR} --strip=1 )
    sh %( touch #{configure} )
  end

  file lib_dir => configure do
    sh %( cp -rf #{RUBY_DIR}/lib #{lib_dir} )
    Dir.glob "#{RUBY_DIR}/ext/*/lib" do |lib|
      sh %( cp -rf #{lib}/* #{lib_dir} ) unless Dir.glob("#{lib}/*").empty?
    end
  end

  TARGETS.each do |sdk, target|
    sdkroot = xcrun sdk, "--show-sdk-path"
    path    = xcrun(sdk, '--find cc').sub %r|/cc$|i, ''
    archs   = target[:archs]
    archs   = archs.select {|arch| ARCHS.include? arch} if ARCHS

    archs.each do |arch|
      namespace arch do

        build_dir    = "#{RUBY_DIR}/.build_#{sdk}_#{arch}"
        makefile     = "#{build_dir}/Makefile"
        libruby_name = "libruby-static.a"
        libruby      = "#{build_dir}/#{libruby_name}"
        lib_arch     = "#{build_dir}/#{lib_name}"
        host         = case arch
          when /arm/    then    'arm-apple-darwin9'
          when /i386/   then   'i386-apple-darwin'
          when /x86_64/ then 'x86_64-apple-darwin'
          else raise 'invalid host'
        end
        flags        = %W[
          -arch #{arch}
          -pipe
          -Os
          -isysroot #{sdkroot}
        ].join ' '
        flags << " -miphoneos-version-min=7.0" if PLATFORM == :ios
        # -gdwarf-2 -no-cpp-precomp -mthumb

        $archs[arch] = build_dir

        directory build_dir

        file makefile => [configure, build_dir] do
          chdir build_dir do
            ENV['PATH']     = "#{path}:#{PATHS}"
            ENV['CPPFLAGS'] = "#{flags}"
            ENV['CFLAGS']   = "#{flags} -fvisibility=hidden"
            ENV['CXXFLAGS'] = "#{flags} -fvisibility=hidden -fvisibility-inline-hidden"
            ENV['LDFLAGS']  = "#{flags} -L#{sdkroot}/usr/lib -lSystem"
            opts = %w[
              --disable-shared
              --with-static-linked-ext
              --without-tcl
              --without-tk
              --disable-install-doc
            ]
            sh %( #{configure} --host=#{host} #{opts.join ' '} )
          end
        end

        file libruby => makefile do
          chdir build_dir do
            sh %( make miniruby )
            sh %( cp `which ruby` miniruby )
            sh %( make )
          end
        end

        file lib_arch => libruby do
          chdir build_dir do
            Dir.glob("#{build_dir}/**/*.a") do |path|
              extract_dir = '.' + lib_name
              libfile_dir = path[%r|#{build_dir}/(.+)\.a$|, 1]
              objs_dir    = "#{extract_dir}/#{libfile_dir}"

              sh %( mkdir -p #{objs_dir} && cp #{path} #{objs_dir} )
              chdir objs_dir do
                sh %( ar x #{File.basename path} )
              end
            end

            objs = Dir.glob "**/*.o"
            sh %( ar -crs #{lib_arch} #{objs.join ' '} )
          end
        end

        file lib_all => lib_arch

        task :configure => makefile

      end# arch
    end
  end

  file lib_all do |t|
    sh %( lipo -create #{t.prerequisites.join ' '} -output #{lib_all} )
  end

  task :make => [lib_all, lib_dir]

end# ruby


namespace :framework do

  src_dir            = "#{ROOT_DIR}/framework"
  framework_dir      = "#{ROOT_DIR}/#{LIB_NAME}.framework"
  versions_dir       = "#{framework_dir}/Versions"
  version_dir        = "#{versions_dir}/A"
  version_header_dir = "#{version_dir}/Headers"
  version_res_dir    = "#{version_dir}/Resources"
  version_lib        = "#{version_dir}/#{LIB_NAME}"
  current_dir        = "#{versions_dir}/Current"
  header_dir         = "#{framework_dir}/Headers"
  res_dir            = "#{framework_dir}/Resources"
  lib                = "#{framework_dir}/#{LIB_NAME}"

  task :clean do
    sh %( rm -rf #{framework_dir} )
  end

  file framework_dir do
    sh %( cp -R #{src_dir}            #{framework_dir} )
    sh %( cp -R #{RUBY_DIR}/include/* #{version_header_dir} )
  end

  $archs.each do |arch, build_dir|
    config_arch_h = "#{version_header_dir}/ruby/config.#{arch}.h"

    namespace arch do

      file config_arch_h => ["ruby:#{arch}:configure", framework_dir] do
        src = Dir.glob "#{build_dir}/.ext/include/**/ruby/config.h"
        raise unless src.size == 1
        sh %( cp #{src.first} #{config_arch_h} )
      end

    end# arch

    task :make => config_arch_h
  end

  file version_lib => ["ruby:make", framework_dir] do
    sh %( cp #{ROOT_DIR}/#{LIB_NAME}.a #{version_lib} )
  end

  task :make => version_lib

  [
    {base: versions_dir,  from: version_dir,        to: current_dir},
    {base: framework_dir, from: version_header_dir, to: header_dir},
    {base: framework_dir, from: version_res_dir,    to: res_dir},
    {base: framework_dir, from: version_lib,        to: lib},
  ].each do |dirs|
    base, dir, symlink = dirs.values_at :base, :from, :to

    file symlink => framework_dir do
      make_symlink base, dir, symlink
    end

    task :make => symlink
  end

end# framework
