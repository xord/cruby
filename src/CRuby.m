#import "CRuby.h"
#import "CRBValue.h"
#include <ruby.h>


#ifndef TAG_RAISE
	#define TAG_RAISE 0x6
#endif


@interface CRuby ()

+ (BOOL)requireExtension:(NSString *)path;

@end


static VALUE
require_extension (int argc, VALUE* argv, VALUE self)
{
	const char* path = argc >= 1 ? StringValueCStr(argv[0]) : NULL;
	if (!path)
		return Qfalse;

	return [CRuby requireExtension:[NSString stringWithUTF8String:path]] ? Qtrue : Qfalse;
}


@implementation CRuby

typedef void (^InitBlock) ();

static NSMutableDictionary *gExtensions = nil;

+ (void)initialize
{
	static BOOL done = NO;
	if (done) return;
	done = YES;

	gExtensions = [[NSMutableDictionary alloc] init];

	ruby_init();

	void Init_enc();
	void Init_ext();
	void Init_prelude();
	void Init_builtin_features();
	void Init_ruby_description();
	Init_enc();
	Init_ext();
	Init_prelude();
	Init_builtin_features();
	Init_ruby_description();

#if RUBY_API_VERSION_MAJOR >= 3
	void rb_call_builtin_inits();
	rb_call_builtin_inits();
#endif

	[self addLibrary:@"CRuby" bundle:[NSBundle bundleForClass:CRuby.class]];

	VALUE mCRuby = rb_define_module("CRuby");
	rb_define_module_function(mCRuby, "require_extension", require_extension, -1);

	[self eval:@
		"module Kernel;"
		"  alias cruby_require__ require;"
		"  def require (*args);"
		"    CRuby.require_extension(*args) || cruby_require__(*args);"
		"  end;"
		"end"];
}

+ (void)finalize
{
	ruby_finalize();
}

+ (BOOL)start:(NSString *)filename
{
	return [self start:filename rescue:^(CRBValue *exception) {
		NSLog(@"Exception: %@", exception.inspect);
	}];
}

+ (BOOL)start:(NSString *)filename rescue:(RescueBlock)rescue
{
	BOOL ret = [self load:filename rescue:rescue];
	[self finalize];
	return ret;
}

+ (BOOL)load:(NSString *)filename
{
	return [self load:filename rescue:^(CRBValue *exception) {
		NSLog(@"Exception: %@", exception.inspect);
	}];
}

+ (BOOL)load:(NSString *)filename rescue:(RescueBlock)rescue
{
	NSString *s   = [NSString stringWithFormat:@"load '%@'", filename];
	CRBValue *ret = [CRuby evaluate:s rescue:rescue];
	return ret && ret.toBOOL;
}

+ (CRBValue *)evaluate:(NSString *)string
{
	return [self evaluate:string rescue:^(CRBValue *exception) {
		NSLog(@"Exception: %@", exception.inspect);
	}];
}

+ (CRBValue *)evaluate:(NSString *)string rescue:(RescueBlock)rescue
{
	[self addResourceDirToLoadPath];
	return [self eval:string rescue:rescue];
}

+ (void)addResourceDirToLoadPath
{
	static BOOL done = NO;
	if (done) return;
	done = YES;

	NSString *res_dir = [NSBundle mainBundle]
		#if TARGET_OS_IPHONE
			.bundlePath;
		#else
			.resourcePath;
		#endif

	[self addLibraryPath:res_dir];
}

+ (CRBValue *)eval:(NSString *)string
{
	return [self eval:string rescue:^(CRBValue *exception) {
		NSLog(@"Exception: %@", exception.inspect);
	}];
}

+ (CRBValue *)eval:(NSString *)string rescue:(RescueBlock)rescue
{
	int state = 0;
	VALUE ret = rb_eval_string_protect(string.UTF8String, &state);

	if (state != 0)
	{
		VALUE exception = rb_errinfo();
		if (state == TAG_RAISE && RTEST(exception))
		{
			rb_set_errinfo(Qnil);
			if (rescue) rescue([[CRBValue alloc] initWithValue:exception]);
		}
		else
			rb_jump_tag(state);
	}

	return ret == Qnil ? nil : [[CRBValue alloc] initWithValue:ret];
}

+ (void)addLibrary:(NSString *)name bundle:(NSBundle *)bundle
{
	NSString *lib_dir = [NSString stringWithFormat:
		#if TARGET_OS_IPHONE
			@"%@/%@.bundle/lib", bundle.bundlePath, name];
		#else
			@"%@/%@.bundle/Contents/Resources/lib", bundle.resourcePath, name];
		#endif
	[self addLibraryPath:lib_dir];
}

+ (void)addLibraryPath:(NSString *)path
{
	[self eval:[NSString stringWithFormat:@"$LOAD_PATH.unshift '%@'", path]];
}

+ (void)addExtension:(NSString *)path init:(InitBlock)init
{
	gExtensions[path] = [init copy];
}

+ (BOOL)requireExtension:(NSString *)path
{
	id init = gExtensions[path];
	if (!init) return NO;

	if (![init isEqual:[NSNull null]])
	{
		gExtensions[path] = [NSNull null];
		((InitBlock) init)();
	}
	return YES;
}

@end
