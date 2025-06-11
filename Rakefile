# -*- mode: ruby -*-

require 'open-uri'
require_relative 'config'


# $ rake build os=X
#   X: macos => build only for macosx.
#   X: ios   => build only for iphoneos and iphonesimulator.
BUILD_OS      = ENV['os']

# $ rake build targets="macosx:x86_64, iphoneos:arm64"
#   => build only for macosx:x86_64 and iphoneos:arm64.
BUILD_TARGETS = (ENV['targets'] || ENV['target'])&.split(/[ ,]+/)

# $ rake download_or_build prebuilt=/path/to/archive
#   => use user specified prebuilt archive.
PREBUILT_PATH = ENV['prebuilt']

# $ rake download_or_build noprebuilt=1
#   => do not download prebuilt archive.
NO_PREBUILT   = (ENV['noprebuilt'] || 0).to_i != 0

# $ rake build yjit_stats=1
#   => same as passing '--yjit-stats' option to 'ruby' command
YJIT_STATS   = (ENV['yjit_stats'] || 0).to_i != 0


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

def rbconfig(rubybin, key)
  `#{rubybin} -rrbconfig -e 'print RbConfig::CONFIG["#{key}"]'`
    .tap {|value| raise "Failed to get RbConfig value for '#{key}'" if value.empty?}
end

def to_rust_target (os, sdk, arch)
  arch = arch.to_s.sub /^arm/, 'aarch'
  os   = {
    macosx:          'darwin',
    iphonesimulator: 'ios-sim',
    iphoneos:        'ios'
  }[sdk.to_sym] or raise 'unknown sdk'

  installed_rust_targets.find {|target| target == "#{arch}-apple-#{os}"}
end

def installed_rust_targets ()
  @installed_rust_targets ||=
    (`rustup target list --installed 2>/dev/null` rescue "").lines chomp: true
end


NAME = "CRuby"

TARGETS = [
  [:macos, :macosx,          [:arm64, :x86_64]],
  [:ios,   :iphonesimulator, [:arm64, :x86_64]],
  [:ios,   :iphoneos,        [:arm64]]
].each {|os, sdk, archs|
  archs.reject! {|arch|
    BUILD_TARGETS && !BUILD_TARGETS.include?("#{sdk}:#{arch}")
  }
}.reject {|os, sdk, archs| BUILD_OS && os.to_s != BUILD_OS || archs.empty?}

ROOT_DIR   = __dir__
INC_DIR    = "#{ROOT_DIR}/include"
RUBY_DIR   = "#{ROOT_DIR}/.ruby"
GEMS_DIR   = "#{ROOT_DIR}/.gems"
OSSL_DIR   = "#{ROOT_DIR}/.openssl"
YAML_DIR   = "#{ROOT_DIR}/.libyaml"
BUILD_DIR  = "#{ROOT_DIR}/.build"
OUTPUT_DIR = "#{ROOT_DIR}/#{NAME}"

RUBY_ARCHIVE = "#{ROOT_DIR}/#{File.basename RUBY_URL}"
OSSL_ARCHIVE = "#{ROOT_DIR}/#{File.basename OSSL_URL}"
YAML_ARCHIVE = "#{ROOT_DIR}/#{File.basename YAML_URL}"

RUBY_CONFIGURE   = "#{RUBY_DIR}/configure"
OSSL_CONFIGURE   = "#{OSSL_DIR}/Configure"
OSSL_CUSTOM_CONF = "#{OSSL_DIR}/Configurations/999-custom.conf"
YAML_CONFIGURE   = "#{YAML_DIR}/configure"

HEADERS_PATCH         = "#{ROOT_DIR}/headers.patch"
HEADERS_PATCH_DEV_DIR = "#{ROOT_DIR}/.headers"

GEMS_TOUCH = "#{GEMS_DIR}/touch"

NATIVE_BUILD_DIR        = "#{BUILD_DIR}/native"
NATIVE_RUBY_INSTALL_DIR = "#{NATIVE_BUILD_DIR}/ruby-install"
NATIVE_RUBY_BIN         = "#{NATIVE_RUBY_INSTALL_DIR}/bin/ruby"

SYSTEM_RUBY_VER = RUBY_VERSION[/^(\d+\.\d+)\.\d+/, 1]
 EMBED_RUBY_VER = CRuby.ruby_version[0..1].join('.')
BASE_RUBY       = SYSTEM_RUBY_VER != EMBED_RUBY_VER ? NATIVE_RUBY_BIN : nil

OUTPUT_XCFRAMEWORK_NAME       = "#{NAME}.xcframework"
OUTPUT_XCFRAMEWORK_DIR        = "#{OUTPUT_DIR}/#{OUTPUT_XCFRAMEWORK_NAME}"
OUTPUT_XCFRAMEWORK_INFO_PLIST = "#{OUTPUT_XCFRAMEWORK_DIR}/Info.plist"

OUTPUT_INC_DIR = "#{OUTPUT_DIR}/include"
OUTPUT_RUBY_H  = "#{OUTPUT_INC_DIR}/ruby.h"

OUTPUT_LIB_DIR          = "#{OUTPUT_DIR}/lib/ruby"
OUTPUT_LIB_DATA_DIR     = "#{OUTPUT_LIB_DIR}/data"
OUTPUT_LIB_RBCONFIG_DIR = "#{OUTPUT_LIB_DIR}/rbconfig"
OUTPUT_RBCONFIG_RB      = "#{OUTPUT_LIB_RBCONFIG_DIR}/rbconfig.rb"

OUTPUT_ARCHIVE   = "#{NAME}_prebuilt-#{CRuby.version}.tar.gz"
PREBUILT_URL     = "#{GITHUB_URL}/releases/download/v#{CRuby.version}/#{OUTPUT_ARCHIVE}"
PREBUILT_ARCHIVE = PREBUILT_PATH || "downloaded_#{OUTPUT_ARCHIVE}"

PATHS = ENV['PATH']
ENV['ac_cv_func_setpgrp_void'] = 'yes'


task :default => :build

desc "delete all temporary files"
task :clean => 'test:clean' do
  sh %( rm -rf #{BUILD_DIR} #{OUTPUT_DIR} #{OUTPUT_ARCHIVE} )
end

desc "delete all generated files"
task :clobber => [:clean, 'test:clobber'] do
  sh %( rm -rf #{GEMS_DIR} #{HEADERS_PATCH_DEV_DIR} )
end

desc "build"
task :build => [OUTPUT_XCFRAMEWORK_INFO_PLIST, OUTPUT_RUBY_H, OUTPUT_RBCONFIG_RB]

desc "test"
task :test => 'test:test'

directory GEMS_DIR
directory BUILD_DIR
directory OUTPUT_DIR
directory OUTPUT_INC_DIR
directory OUTPUT_LIB_DATA_DIR
directory OUTPUT_LIB_RBCONFIG_DIR

[
  [RUBY_DIR, RUBY_URL, RUBY_ARCHIVE, RUBY_CONFIGURE],
  [OSSL_DIR, OSSL_URL, OSSL_ARCHIVE, OSSL_CONFIGURE],
  [YAML_DIR, YAML_URL, YAML_ARCHIVE, YAML_CONFIGURE]
].each do |dir, url, archive, configure|
  task :clobber do
    sh %( rm -rf #{archive} #{dir} )
  end

  directory dir

  file archive do
    download url, archive
  end

  file configure => [dir, archive] do
    sh %( tar xzf #{archive} --directory=#{dir} --strip=1 )
    sh %( touch #{configure} )
  end
end

file RUBY_CONFIGURE do
  # append 'CRuby_init()' func to ruby.c
  modify_file "#{RUBY_DIR}/ruby.c" do |s|
    s + <<~EOS
      void CRuby_init (void (*init_prelude)(), bool yjit)
      {
        ruby_init();

        ruby_cmdline_options_t opt;
        cmdline_options_init(&opt);

        #if USE_YJIT
          FEATURE_SET(opt.features, FEATURE_BIT(yjit));
          setup_yjit_options("#{YJIT_STATS ? 'stats' : ''}");
          opt.yjit = yjit;
        #endif

        Init_ruby_description(&opt);
        Init_enc();
        Init_ext();
        Init_extra_exts();
        if (init_prelude) init_prelude();
        #if RUBY_API_VERSION_MAJOR >= 3
          rb_call_builtin_inits();
        #endif
        Init_builtin_features();

        #if USE_YJIT
          rb_yjit_init(opt.yjit);
        #endif

        rb_jit_cont_init();
      }
    EOS
  end

  # disable calling system()
  modify_file "#{RUBY_DIR}/vm_dump.c" do |s|
    s.gsub <<~FROM, <<~TO
      int r = system(buf);
    FROM
      #if defined(HAVE_SYSTEM)
        int r = system(buf);
      #else
        int r = -1;
      #endif
    TO
  end

  # use sys_icache_invalidate() on iphoneos
  modify_file "#{RUBY_DIR}/yjit.c" do |s|
    <<~HEADER + s.gsub(<<~FROM, <<~TO)
      #include <TargetConditionals.h>
      #if TARGET_OS_IOS && !TARGET_OS_SIMULATOR
      #include <libkern/OSCacheControl.h>
      #endif
    HEADER
      __builtin___clear_cache(start, end);
    FROM
      #if TARGET_OS_IOS && !TARGET_OS_SIMULATOR
        sys_icache_invalidate(start, (size_t) ((char*) end - (char*) start));
      #else
        __builtin___clear_cache(start, end);
      #endif
    TO
  end
end

file RUBY_CONFIGURE => GEMS_TOUCH do
  # place the bundled gems and the gems specified in the Gemfile in the same
  # directory structure as the standard library

  sh %( rm -rf #{RUBY_DIR}/.bundle/gems/* )
  sh %( rm -rf #{RUBY_DIR}/lib/prism* )

  rubyver     = rbconfig('ruby', :ruby_version)
  locked_gems = Dir.glob("#{GEMS_DIR}/ruby/#{rubyver}/cache/*.gem")
    .map {"'#{_1}'"}.join ' '
  sh %( cp #{locked_gems} #{RUBY_DIR}/gems/ ) unless locked_gems.empty?

  to_ver_str = -> ver {ver.split('.').map {|s| '%03d' % s.to_i}.join}
  gems       = Dir.glob("#{RUBY_DIR}/gems/*.gem")
    .map {File.basename _1}
    .each.with_object({}) {|filename, hash|
      name, ver = /(.+)\-([\.\d]+)\.gem/.match(filename).captures
      (hash[name] ||= []) << ver
    }
    .transform_values {|vers| vers.sort {to_ver_str[_1] <=> to_ver_str[_2]}.max}

  gems.each do |name, ver|
    sh %( gem unpack --target=#{RUBY_DIR}/ext/ #{RUBY_DIR}/gems/#{name}-#{ver}.gem )
    sh %( cp -r #{RUBY_DIR}/ext/#{name}-#{ver}/lib/* #{RUBY_DIR}/lib/ )
  end

  # disable the bundled gems mechanism
  File.write "#{RUBY_DIR}/gems/bundled_gems", ''
  sh %( rm -rf #{RUBY_DIR}/gems/*.gem )

  # avoid duplication of prism sources between embedded and gem versions
  Dir.glob "#{RUBY_DIR}/ext/prism-*/**/*.{c,h}" do |path|
    # avoid duplicated symbols
    modify_file path do |src|
      src
        .gsub(/([^\w])(pm_[a-z_]+)/) {"#{$1}gem_#{$2}"}
        .gsub(/gem_(pm_[a-z_]+)\.h/) {"#{$1}.h"}
    end
  end
  modify_file "#{RUBY_DIR}/prism_init.c" do |src|
    # avoid duplicate registration of 'prism/prism.so'
    src.sub /^.*prism\/prism\.so.*$/, ''
  end
end

file GEMS_TOUCH => GEMS_DIR do
  sh %( bundle install )
  sh %( touch #{GEMS_TOUCH} )
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

file OUTPUT_XCFRAMEWORK_INFO_PLIST do |t|
  libs = t.prerequisites.select {|s| s.end_with? '.a'}.map {|s| "-library #{s}"}
  sh %( rm -rf #{OUTPUT_XCFRAMEWORK_DIR} )
  sh %( xcodebuild -create-xcframework -output #{OUTPUT_XCFRAMEWORK_DIR} #{libs.join ' '} )
end

file OUTPUT_RUBY_H => [RUBY_CONFIGURE, OUTPUT_INC_DIR, NATIVE_RUBY_BIN] do
  lib_dir_ver = File.basename rbconfig(NATIVE_RUBY_BIN, :rubylibdir)

  sh %( cp -rf #{RUBY_DIR}/include/* #{OUTPUT_INC_DIR} )
  sh %( cp -rf #{INC_DIR}/* #{OUTPUT_INC_DIR})
  sh %( patch -p1 -d #{OUTPUT_INC_DIR} < #{HEADERS_PATCH} )

  modify_file "#{OUTPUT_INC_DIR}/CRubyConfig.h" do |s|
    s.sub /#define\s+CRUBY_LIB_DIR_VERSION\s+@/, %|#define CRUBY_LIB_DIR_VERSION @"#{lib_dir_ver}"|
  end
end

file OUTPUT_RBCONFIG_RB => [
  RUBY_CONFIGURE, OUTPUT_LIB_DATA_DIR, OUTPUT_LIB_RBCONFIG_DIR, NATIVE_RUBY_BIN
] do
  lib_dir      = rbconfig NATIVE_RUBY_BIN, :rubylibprefix
  lib_arch_dir = rbconfig NATIVE_RUBY_BIN, :rubyarchdir

  Dir.glob "#{RUBY_DIR}/ext/*/data" do |data_dir|
    sh %( cp -r #{data_dir}/* #{OUTPUT_LIB_DATA_DIR} )
  end

  write_file OUTPUT_RBCONFIG_RB, 'require "rbconfig-#{CRUBY_BUILD_SDK_AND_ARCH}"'
  sh %( cp -rf #{lib_dir}/* #{OUTPUT_LIB_DIR} )
  sh %( rm -rf #{OUTPUT_LIB_DIR}#{lib_arch_dir.sub /^#{lib_dir}/, ''} )
end


desc "archive built files for deploy"
task :archive => OUTPUT_ARCHIVE

file OUTPUT_ARCHIVE => :build do
  sh %( tar cvzf #{OUTPUT_ARCHIVE} #{OUTPUT_DIR.sub(ROOT_DIR + '/', '')} )
end

desc "download prebuilt binary or build all"
task :download_or_build => PREBUILT_ARCHIVE do
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


TARGETS.each do |os, sdk, archs|
  sdk_root = xcrun sdk, '--show-sdk-path'
  cc_dir   = File.dirname xcrun(sdk, '--find cc')

  build_dir       = "#{BUILD_DIR}/#{sdk}"
  output_dir      = "#{build_dir}/output"
  output_lib_name = "libruby-static.a"
  output_lib_file = "#{output_dir}/#{output_lib_name}"

  archs.each do |arch|
    build_arch_dir   = "#{build_dir}/#{arch}"
    ruby_dir         = "#{build_arch_dir}/ruby"
    ossl_dir         = "#{build_arch_dir}/openssl"
    yaml_dir         = "#{build_arch_dir}/libyaml"
    ossl_install_dir = "#{build_arch_dir}/openssl-install"
    yaml_install_dir = "#{build_arch_dir}/libyaml-install"

    libruby_ver = ruby25_or_higher? ? ".#{CRuby.ruby_version[0, 2].join '.'}" : ""
    libruby     = "#{ruby_dir}/libruby#{libruby_ver}-static.a"
    libossl     = "#{ossl_install_dir}/lib/libssl.a"
    libyaml     = "#{yaml_install_dir}/lib/libyaml.a"

    rbconfig_rb = "#{OUTPUT_LIB_RBCONFIG_DIR}/rbconfig-#{sdk}-#{arch}.rb"

    arch_lib_file = "#{build_arch_dir}/#{output_lib_name}"

    ios  = os == :ios
    arm  = arch =~ /^arm/
    host = "#{arm ? 'arm' : arch}-#{ios ? 'iphone' : 'apple'}-darwin"

    namespace :ruby do
      config_h     = "#{OUTPUT_INC_DIR}/ruby/config-#{sdk}-#{arch}.h"
      config_h_dir = File.dirname config_h
      makefile     = "#{ruby_dir}/Makefile"
      isysroot     = "-isysroot #{sdk_root}"
      flags        = "-pipe -Os #{isysroot}" # -gdwarf-2 -no-cpp-precomp -mthumb

      if "#{sdk}:#{arch}" == 'iphonesimulator:x86_64'
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

      makefile_dep = [RUBY_CONFIGURE, ruby_dir, libossl, libyaml, *missing_headers]
      makefile_dep << BASE_RUBY if BASE_RUBY
      file makefile => makefile_dep do
        chdir ruby_dir do
          rustc_target = to_rust_target os, sdk, arch
          yjit         = rustc_target != nil && !ios
          flags       += ' -DYJIT_STATS=1' if yjit && YJIT_STATS

          enables  = yjit ? %w[jit-support yjit] : []
          disables = %w[shared dln install-doc]
          withouts = %w[fiddle bigdecimal readline]
          nofuncs  = %w[backtrace system syscall __syscall getentropy]

          envs = {
            PATH:     "#{cc_dir}:#{PATHS}",
            CC:       "clang -arch #{arch}",
            CPP:      "clang -arch #{arch} -E",
            CXX:      "clang++ -arch #{arch}",
            CXXCPP:   "clang++ -arch #{arch} -E",
            CPPFLAGS: "#{flags}",
            CFLAGS:   "#{flags} -fvisibility=hidden",
            CXXFLAGS: "-fvisibility-inline-hidden",
            ASFLAGS:  "#{isysroot}",
            LDFLAGS:  "#{flags} -L#{sdk_root}/usr/lib -framework Security",
            RUSTC:    rustc_target&.then {|t| "rustc --target=#{t}"}
          }.compact.map {|k, v| "#{k}='#{v}'"}.join ' '
          opts = %W[
            --host=#{host}
            --with-static-linked-ext
            --with-openssl-dir=#{ossl_install_dir}
            --with-libyaml-dir=#{yaml_install_dir}
          ]
          opts += enables.map  {|s| "--enable-#{s}"}
          opts += disables.map {|s| "--disable-#{s}"}
          opts += withouts.map {|s| "--without-#{s}"}
          opts += nofuncs .map {|s| "ac_cv_func_#{s}=no"} if ios
          opts << "--with-arch=#{arch}" unless arm
          opts << "--with-baseruby=#{BASE_RUBY}" if BASE_RUBY

          sh %( #{envs} #{RUBY_CONFIGURE} #{opts.join ' '} )

          modify_file makefile do |s|
            # avoid link error on linking exe/ruby
            s = s.gsub /^.*PROGRAM.*:.*exe\/.*PROGRAM.*$/, ''
            s += "$(LIBRUBY_A): $(YJIT_LIBS)" if yjit
            s
          end
        end
      end

      file config_h => [makefile, config_h_dir] do
        src = Dir.glob("#{ruby_dir}/.ext/include/**/ruby/config.h").first
        raise 'no config.h' unless src

        sh %( cp #{src} #{config_h} )
      end

      file libruby => [makefile, config_h] do
        chdir ruby_dir do
          sh %( make -j -s )
        end
      end
    end# ruby

    namespace :openssl do
      directory ossl_dir
      directory ossl_install_dir

      file libossl => [OSSL_CONFIGURE, OSSL_CUSTOM_CONF, ossl_dir] do
        chdir ossl_dir do
          envs = {
            CROSS_COMPILE: "#{cc_dir}/"
          }.map {|k, v| "#{k}='#{v}'"}.join ' '
          opts = %W[
            --prefix=#{ossl_install_dir}
            no-shared
            no-tests
          ].join ' '
          sh %( #{envs} #{OSSL_CONFIGURE} #{opts} #{sdk}-#{arch} )
          sh %( #{envs} make -j -s )
          sh %( make install_sw | grep include )
        end
      end
    end# openssl

    namespace :libyaml do
      directory yaml_dir
      directory yaml_install_dir

      file libyaml => [YAML_CONFIGURE, yaml_dir] do
        chdir yaml_dir do
          envs = {
            CC: "xcrun --sdk #{sdk} cc -arch #{arch}"
          }.map {|k, v| "#{k}='#{v}'"}.join ' '
          opts = %W[
            --prefix=#{yaml_install_dir}
            --host=#{host}
            --enable-static
            --disable-shared
          ].join ' '
          sh %( #{envs} #{YAML_CONFIGURE} #{opts} )
          sh %( #{envs} make -j -s )
          sh %( make install )
        end
      end
    end# libyaml

    file rbconfig_rb => [libruby, OUTPUT_LIB_RBCONFIG_DIR] do
      sh %( cp "#{ruby_dir}/rbconfig.rb" #{rbconfig_rb} )
      modify_file rbconfig_rb do |s|
        s.sub /TOPDIR\s*=.*$/,
          "TOPDIR = File.dirname(__FILE__).chomp!('/lib/ruby/rbconfig')"
      end
    end

    file arch_lib_file => [libruby, libossl, libyaml] do
      extract_dir = "#{build_arch_dir}/.#{File.basename arch_lib_file}"
      excludes    = %w[dmyenc.o dmyext.o]
      extra_objs  = %w[enc ext].map {|s| "#{ruby_dir}/#{s}/#{s}init.o"}

      [ruby_dir, ossl_install_dir, yaml_install_dir]
        .map {|dir| Dir.glob "#{dir}/**/*.a"}
        .flatten
        .reject {|path| excludes.any? {|s| path.include? s}}
        .each do |a_path|

        a_dir    = a_path[%r|#{build_arch_dir}/(.+)\.a$|, 1]
        objs_dir = "#{extract_dir}/#{a_dir}"

        sh %( mkdir -p #{objs_dir} && cp #{a_path} #{objs_dir} )
        chdir objs_dir do
          a_name = File.basename a_path
          objs   = `ar t #{a_name}`.lines(chomp: true).select {_1.end_with? '.o'}
          if objs.tally.all? {|_, count| count == 1}
            sh %( ar x #{a_name} )
          else
            objs.tally.each do |obj, count|
              (1..count).each do |nth|
                sh %( ar x #{a_name} #{obj} )
                sh %( mv #{obj} #{nth}_#{obj} ) if count >= 2
                sh %( ar d #{a_name} #{obj} )
              end
            end
          end
        end
      end

      chdir build_arch_dir do
        objs = Dir.glob("#{extract_dir}/**/*.o")
          .reject {|path| excludes.any? {|s| path.include? s}}
        sh %( ar -crs #{arch_lib_file} #{objs.join ' '} #{extra_objs.join ' '} )
      end
    end

    file output_lib_file => [arch_lib_file, rbconfig_rb]
  end

  namespace :output do
    directory output_dir

    file output_lib_file => output_dir do |t|
      libs = t.prerequisites.select {|s| s.end_with? '.a'}
      sh %( lipo -create #{libs.join ' '} -output #{output_lib_file} )
    end

    file OUTPUT_XCFRAMEWORK_INFO_PLIST => output_lib_file
  end# output
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
      sh %( make -j -s )
      sh %( make -s install )
    end
  end

  file ossl_lib => [OSSL_CONFIGURE, ossl_dir] do
    chdir ossl_dir do
      sh %( #{OSSL_DIR}/config --prefix=#{ossl_install_dir} )
      sh %( make -j -s )
      sh %( make -s install_sw )
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


namespace :test do

  tasks = %i{clobber clean test}

  tasks.each do |name|
    task name do
      Dir.chdir 'test/macos' do
        sh %( rake #{name} )
      end
    end
  end

end# test
