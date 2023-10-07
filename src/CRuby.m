#import "CRuby.h"
#import "CRubyConfig.h"
#import "CRBValue.h"
#include <ruby.h>
#include <ruby/version.h>


#ifndef TAG_RAISE
	#define TAG_RAISE 0x6
#endif


@interface CRuby ()

+ (BOOL)requireExtension:(NSString*)path;

@end


static VALUE
require_extension (int argc, VALUE* argv, VALUE self)
{
	const char* path = argc >= 1 ? StringValueCStr(argv[0]) : NULL;
	if (!path) return Qfalse;

	return [CRuby requireExtension:[NSString stringWithUTF8String:path]] ? Qtrue : Qfalse;
}


@implementation CRuby

typedef void (^InitBlock) ();

static NSMutableDictionary* gExtensions = nil;

static BOOL gYJIT = NO;

+ (void)finalize
{
	ruby_finalize();
}

+ (void)setupCRuby
{
	static BOOL done = NO;
	if (done) return;
	done = YES;

	gExtensions = [[NSMutableDictionary alloc] init];

	void CRuby_init(void (*)(), bool);
	#ifdef CRUBY_TEST
		void* Init_prelude = NULL;
	#else
		void Init_prelude();
	#endif
	CRuby_init(Init_prelude, gYJIT);

	[self addLibrary:@"CRuby" bundle:[NSBundle bundleForClass:CRuby.class]];

	VALUE mCRuby = rb_define_module("CRuby");
	rb_define_module_function(mCRuby, "require_extension", require_extension, -1);

	[self eval:@
		"module Kernel;"
		"  alias cruby_require__ require;"
		"  def require(*args);"
		"    CRuby.require_extension(*args) || cruby_require__(*args);"
		"  end;"
		"end"];

	[self eval: [NSString stringWithFormat:
		@"Object.const_set(:CRUBY_BUILD_SDK_AND_ARCH, %@)",
		[self getCRubyBuildSDKAndArch]]];
}

+ (NSString*)getCRubyBuildSDKAndArch
{
#if   defined(CRUBY_IPHONESIMULATOR_X86_64)
	return         @"'iphonesimulator-x86_64'";
#elif defined(CRUBY_IPHONESIMULATOR_ARM64)
	return         @"'iphonesimulator-arm64'";
#elif defined(CRUBY_IPHONEOS_X86_64)
	return         @"'iphoneos-x86_64'";
#elif defined(CRUBY_IPHONEOS_ARM64)
	return         @"'iphoneos-arm64'";
#elif defined(CRUBY_MACOSX_X86_64)
	return         @"'macosx-x86_64'";
#elif defined(CRUBY_MACOSX_ARM64)
	return         @"'macosx-arm64'";
#else
	return @"nil";
#endif
}

+ (BOOL)start:(NSString*)filename
{
	return [self start:filename rescue:^(CRBValue* exception) {
		NSLog(@"Exception: %@", exception.inspect);
	}];
}

+ (BOOL)start:(NSString*)filename rescue:(RescueBlock)rescue
{
	BOOL ret = [self load:filename rescue:rescue];
	[self finalize];
	return ret;
}

+ (BOOL)load:(NSString*)filename
{
	return [self load:filename rescue:^(CRBValue* exception) {
		NSLog(@"Exception: %@", exception.inspect);
	}];
}

+ (BOOL)load:(NSString*)filename rescue:(RescueBlock)rescue
{
	NSString* s   = [NSString stringWithFormat:@"load '%@'", filename];
	CRBValue* ret = [CRuby evaluate:s rescue:rescue];
	return ret && ret.toBOOL;
}

+ (CRBValue*)evaluate:(NSString*)string
{
	return [self evaluate:string rescue:^(CRBValue* exception) {
		NSLog(@"Exception: %@", exception.inspect);
	}];
}

+ (CRBValue*)evaluate:(NSString*)string rescue:(RescueBlock)rescue
{
	[self addResourceDirToLoadPath];
	return [self eval:string rescue:rescue];
}

+ (void)addResourceDirToLoadPath
{
	static BOOL done = NO;
	if (done) return;
	done = YES;

	NSString* res_dir = [NSBundle mainBundle]
		#if TARGET_OS_IPHONE
			.bundlePath;
		#else
			.resourcePath;
		#endif

	[self addLibraryPath:res_dir];
}

+ (CRBValue*)eval:(NSString*)string
{
	return [self eval:string rescue:^(CRBValue* exception) {
		NSLog(@"Exception: %@", exception.inspect);
	}];
}

+ (CRBValue*)eval:(NSString*)string rescue:(RescueBlock)rescue
{
	[self setupCRuby];

	int state = 0;
	VALUE ret = rb_eval_string_protect(string.UTF8String, &state);

	if (state != 0)
	{
		VALUE exception = rb_errinfo();
		if (state == TAG_RAISE && RTEST(exception))
		{
			rb_set_errinfo(Qnil);
			if (rescue) rescue([CRBValue valueWithVALUE:exception]);
		}
		else
			rb_jump_tag(state);
	}

	return ret == Qnil ? nil : [CRBValue valueWithVALUE:ret];
}

+ (void)addLibrary:(NSString*)name bundle:(NSBundle*)bundle
{
	NSString* lib_dir = [NSString stringWithFormat:
		#if TARGET_OS_IPHONE
			@"%@/%@.bundle/lib", bundle.bundlePath, name];
		#else
			@"%@/%@.bundle/Contents/Resources/lib", bundle.resourcePath, name];
		#endif
	[self addLibraryPath:lib_dir];
}

+ (void)addLibraryPath:(NSString*)path
{
	[self eval:[NSString stringWithFormat:@"$LOAD_PATH.unshift '%@'", path]];
}

+ (void)addExtension:(NSString*)path init:(InitBlock)init
{
	[gExtensions[path] release];
	gExtensions[path] = [init copy];
}

+ (BOOL)requireExtension:(NSString*)path
{
	id init = gExtensions[path];
	if (!init) return NO;

	[gExtensions removeObjectForKey:path];

	((InitBlock) init)();
	[init release];
	return YES;
}

+ (void)enableYJIT
{
	// must be called before first 'eval' call
	gYJIT = YES;
}

@end
