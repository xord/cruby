# -*- mode: ruby -*-


require 'open-uri'
require_relative 'config'


# $ rake build platform=X
#   X: macos => build only for macosx.
#   X: ios   => build only for iphoneos and iphonesimulator.
BUILD_PLATFORM = ENV['platform']

# $ rake build targets="macosx:x86_64, iphoneos:arm64"
#   => build only for macosx:x86_64 and iphoneos:arm64.
BUILD_TARGETS  = ENV['targets']&.split(/[ ,]+/)

# $ rake download_or_build_all noprebuilt=1
#   => do not download prebuild archive.
NO_PREBUILT    = (ENV['noprebuilt'] || 0).to_i != 0


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
  write_file path, URI.open(url) {|f| f.read}
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


TARGETS = [
  %w[macos macosx          x86_64],
  #%w[macos macosx          arm64],
  %w[ios   iphonesimulator x86_64],
  #%w[ios   iphonesimulator arm64],
  %w[ios   iphoneos        arm64]
].reject {|platform, sdk, arch|
  (BUILD_PLATFORM && platform != BUILD_PLATFORM) ||
  (BUILD_TARGETS  && !BUILD_TARGETS.include?("#{sdk}:#{arch}"))
}

NAME        = "CRuby"
OUTPUT_NAME = "#{NAME}.xcframework"

ROOT_DIR   = __dir__
INC_DIR    = "#{ROOT_DIR}/include"
RUBY_DIR   = "#{ROOT_DIR}/.ruby"
OSSL_DIR   = "#{ROOT_DIR}/.openssl"
BUILD_DIR  = "#{ROOT_DIR}/.build"
OUTPUT_DIR = "#{ROOT_DIR}/#{OUTPUT_NAME}"

RUBY_CONFIGURE   = "#{RUBY_DIR}/configure"
OSSL_CONFIGURE   = "#{OSSL_DIR}/Configure"
OSSL_CUSTOM_CONF = "#{OSSL_DIR}/Configurations/999-custom.conf"

HEADERS_PATCH         = "#{ROOT_DIR}/headers.patch"
HEADERS_PATCH_DEV_DIR = "#{ROOT_DIR}/.headers"

NATIVE_BUILD_DIR        = "#{BUILD_DIR}/native"
NATIVE_RUBY_INSTALL_DIR = "#{NATIVE_BUILD_DIR}/ruby-install"
NATIVE_RUBY_BIN         = "#{NATIVE_RUBY_INSTALL_DIR}/bin/ruby"

SYSTEM_RUBY_VER = RUBY_VERSION[/^(\d+\.\d+)\.\d+/, 1]
 EMBED_RUBY_VER = CRuby.ruby_version[0..1].join('.')
BASE_RUBY       = SYSTEM_RUBY_VER != EMBED_RUBY_VER ? NATIVE_RUBY_BIN : nil

FRAMEWORK_NAME         = "#{NAME}.framework"
XCFRAMEWORK_INFO_PLIST = "#{OUTPUT_DIR}/Info.plist"

OUTPUT_ARCHIVE   = "#{NAME}_prebuilt-#{CRuby.version}.tar.gz"
PREBUILT_URL     = "#{GITHUB_URL}/releases/download/v#{CRuby.version}/#{OUTPUT_ARCHIVE}"
PREBUILT_ARCHIVE = "downloaded_#{OUTPUT_ARCHIVE}"

PATHS = ENV['PATH']
ENV['ac_cv_func_setpgrp_void'] = 'yes'


task :default => :build

desc "delete all temporary files"
task :clean do
  sh %( rm -rf #{BUILD_DIR} #{OUTPUT_DIR} #{OUTPUT_ARCHIVE} )
end

desc "delete all generated files"
task :clobber => :clean do
  sh %( rm -rf #{HEADERS_PATCH_DEV_DIR} )
end

desc "build"
task :build => XCFRAMEWORK_INFO_PLIST

directory BUILD_DIR
directory OUTPUT_DIR

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

file OSSL_CUSTOM_CONF do
  sdk_path = -> sdk {xcrun sdk, '--show-sdk-path'}

  write_file OSSL_CUSTOM_CONF, <<~END
    my %targets = (
      "macosx-x86_64" => {
        inherit_from => ["darwin64-x86_64-cc"],
        cflags       => add("-isysroot #{sdk_path[:macosx]}"),
      },
      "macosx-arm64" => {
        inherit_from => ["darwin64-arm64-cc"],
        cflags       => add("-isysroot #{sdk_path[:macosx]}"),
      },
      "iphonesimulator-x86_64" => {
        inherit_from => ["ios-common"],
        cflags       => add("-isysroot #{sdk_path[:iphonesimulator]} -arch x86_64 -fno-common"),
      },
      "iphonesimulator-arm64" => {
        inherit_from => ["ios-common"],
        cflags       => add("-isysroot #{sdk_path[:iphonesimulator]} -arch arm64 -fno-common"),
      },
      "iphoneos-arm64" => {
        inherit_from => ["ios64-xcrun"],
        CC           => "cc",
        cflags       => add("-isysroot #{sdk_path[:iphoneos]}"),
      },
    );
  END
end

file XCFRAMEWORK_INFO_PLIST do |t|
  frameworks = t.prerequisites
    .select {|name| name =~ /\.framework$/}
    .map {|framework| "-framework #{framework}"}
  sh %( rm -rf #{OUTPUT_DIR} )
  sh %( xcodebuild -create-xcframework -output #{OUTPUT_DIR} #{frameworks.join ' '} )
end


desc "archive built files for deploy"
task :archive => OUTPUT_ARCHIVE

file OUTPUT_ARCHIVE => :build do
  sh %( tar cvzf #{OUTPUT_ARCHIVE} #{OUTPUT_DIR.sub(ROOT_DIR + '/', '')} )
end

desc "download prebuilt binary or build all"
task :download_or_build_all => PREBUILT_ARCHIVE do
  if File.exist?(PREBUILT_ARCHIVE)
    sh %( tar xzf #{PREBUILT_ARCHIVE} )
  else
    sh %( rake build )
  end
end

file PREBUILT_ARCHIVE do
  next if NO_PREBUILT
  download PREBUILT_URL, PREBUILT_ARCHIVE rescue OpenURI::HTTPError
end


TARGETS.each do |platform, sdk, arch|
  sdk_root = xcrun sdk, '--show-sdk-path'
  cc_dir   = File.dirname xcrun(sdk, '--find cc')

  build_dir = "#{BUILD_DIR}/#{sdk}_#{arch}"
  ruby_dir  = "#{build_dir}/ruby"
  ossl_dir  = "#{build_dir}/openssl"

  ossl_install_dir = "#{build_dir}/openssl-install"
  ossl_config_h    = "#{ossl_install_dir}/include/openssl/opensslconf.h"

  libruby_ver = ruby25_or_higher? ? ".#{CRuby.ruby_version[0, 2].join '.'}" : ""
  libruby     = "#{ruby_dir}/libruby#{libruby_ver}-static.a"
  libossl     = "#{ossl_dir}/libssl.a"

  framework_dir      = "#{build_dir}/#{FRAMEWORK_NAME}"
  framework_inc_dir  = "#{framework_dir}/Headers"
  framework_res_dir  = "#{framework_dir}/Resources"
  framework_lib_file = "#{framework_dir}/#{NAME}"

  ios = platform == 'ios'
  arm = arch =~ /^arm/

  namespace :ruby do
    config_h     = "#{framework_inc_dir}/ruby/config-#{platform}_#{arch}.h"
    config_h_dir = File.dirname config_h
    makefile     = "#{ruby_dir}/Makefile"
    host         = "#{arm ? 'arm' : arch}-#{ios ? 'iphone' : 'apple'}-darwin"
    isysroot     = "-isysroot #{sdk_root}"
    flags        = "-pipe -Os #{isysroot}" # -gdwarf-2 -no-cpp-precomp -mthumb

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
          'ASFLAGS'  => "#{isysroot}",
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

      # avoid crash on AdMob initialization.
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
    directory ossl_dir
    directory ossl_install_dir

    file libossl => [OSSL_CONFIGURE, OSSL_CUSTOM_CONF, ossl_dir] do
      chdir ossl_dir do
        envs = "CROSS_COMPILE=#{cc_dir}/"
        opts = %W[
          --prefix=#{ossl_install_dir}
          no-shared
        ]
        sh %( #{envs} #{OSSL_CONFIGURE} #{opts.join ' '} #{sdk}-#{arch} )
        sh %( #{envs} make )
      end
    end

    file ossl_config_h => [libossl, ossl_install_dir] do
      chdir ossl_dir do
        sh %( make install_sw | grep include )
      end
    end
  end# openssl

  namespace :framework do
    inc_ruby_h  = "#{framework_inc_dir}/ruby.h"
    res_json_rb = "#{framework_res_dir}/json.rb"

    directory framework_dir
    directory framework_inc_dir
    directory framework_res_dir

    file inc_ruby_h => [RUBY_CONFIGURE, framework_inc_dir] do
      sh %( cp -rf #{RUBY_DIR}/include/* #{framework_inc_dir} )
      sh %( cp -rf #{INC_DIR}/* #{framework_inc_dir})
      sh %( patch -p1 -d #{framework_inc_dir} < #{HEADERS_PATCH} )
    end

    file res_json_rb => [RUBY_CONFIGURE, framework_res_dir] do
      sh %( cp -rf #{RUBY_DIR}/lib/* #{framework_res_dir} )
      Dir.glob "#{RUBY_DIR}/ext/*/lib" do |lib|
        sh %( cp -rf #{lib}/* #{framework_res_dir} ) unless Dir.glob("#{lib}/*").empty?
      end
    end

    file framework_lib_file => [libruby, libossl] do
      extract_dir = "#{build_dir}/.#{File.basename framework_lib_file}"
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
        objs = Dir.glob("#{extract_dir}/**/*.o")
          .reject {|path| excludes.any? {|s| path.include? s}}
        sh %( ar -crs #{framework_lib_file} #{objs.join ' '} #{extra_objs.join ' '} )
      end
    end

    file XCFRAMEWORK_INFO_PLIST => [framework_dir, framework_lib_file, inc_ruby_h, res_json_rb]
  end# framework
end


namespace :native do
  ruby_dir         = "#{NATIVE_BUILD_DIR}/ruby"
  ossl_dir         = "#{NATIVE_BUILD_DIR}/openssl"
  ossl_install_dir = "#{NATIVE_BUILD_DIR}/openssl-install"
  ossl_lib         = "#{ossl_install_dir}/lib/libssl.a"

  directory ruby_dir
  directory ossl_dir

  file NATIVE_RUBY_BIN => [RUBY_CONFIGURE, ruby_dir, ossl_lib] do
    chdir ruby_dir do
      opts = {
        'prefix'           => NATIVE_RUBY_INSTALL_DIR,
        'with-openssl-dir' => ossl_install_dir
      }.map {|k, v| "--#{k}=#{v}"}
      sh %( #{RUBY_CONFIGURE} #{opts.join ' '} --disable-install-doc )
      sh %( make && make install )
    end
  end

  file ossl_lib => [OSSL_CONFIGURE, ossl_dir] do
    chdir ossl_dir do
      sh %( #{OSSL_DIR}/config --prefix=#{ossl_install_dir} )
      sh %( make && make install_sw )
    end
  end
end# native


namespace :headers_patch do
  task :setup => RUBY_CONFIGURE do
    sh %( cp -r "#{RUBY_DIR}/include" #{HEADERS_PATCH_DEV_DIR} )
    chdir HEADERS_PATCH_DEV_DIR do
      sh %( git init && git add . && git commit -m '-' )
      sh %( patch -p1 -d . < #{HEADERS_PATCH} )
    end
  end

  task :update do
    chdir HEADERS_PATCH_DEV_DIR do
      sh %( git diff > #{HEADERS_PATCH} )
    end
  end
end# headers_patch
