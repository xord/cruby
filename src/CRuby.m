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

	[self setupStandardExtensions];
	[self addLibrary:@"CRuby" bundle:[NSBundle bundleForClass:CRuby.class]];

	rb_define_global_function("require_extension", require_extension, -1);

	[self eval:@
		"alias require_original require;"
		"def require (*args)"
		"  require_extension(*args) || require_original(*args);"
		"end"];

	void Init_encdb();
	Init_encdb();
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

	return [[CRBValue alloc] initWithValue:ret];
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

+ (void)setupStandardExtensions
{
	void Init_bigdecimal();
	void Init_continuation();
	void Init_coverage();
	void Init_date_core();
	void Init_dbm();
	void Init_bubblebabble();
	void Init_digest();
	void Init_md5();
	void Init_rmd160();
	void Init_sha1();
	void Init_sha2();
	void Init_callback();
	void Init_dl();
	void Init_etc();
	void Init_fcntl();
	void Init_fiber();
	void Init_fiddle();
	void Init_console();
	void Init_nonblock();
	void Init_wait();
	void Init_generator();
	void Init_parser();
	void Init_nkf();
	void Init_objspace();
	void Init_pathname();
	void Init_psych();
	void Init_pty();
	void Init_cparse();
	void Init_sizeof();
	void Init_readline();
	void Init_ripper();
	void Init_sdbm();
	void Init_socket();
	void Init_stringio();
	void Init_strscan();
	void Init_syslog();
	void Init_zlib();

	//[self addExtension:@"bigdecimal.so"       init:^{Init_bigdecimal();}];
	[self addExtension:@"continuation"        init:^{Init_continuation();}];
	[self addExtension:@"coverage"            init:^{Init_coverage();}];
	[self addExtension:@"date_core"           init:^{Init_date_core();}];
	[self addExtension:@"dbm"                 init:^{Init_dbm();}];
	[self addExtension:@"digest/bubblebabble" init:^{Init_bubblebabble();}];
	[self addExtension:@"digest.so"           init:^{Init_digest();}];
	[self addExtension:@"digest/md5"          init:^{Init_md5();}];
	[self addExtension:@"digest/rmd160"       init:^{Init_rmd160();}];
	[self addExtension:@"digest/sha1"         init:^{Init_sha1();}];
	[self addExtension:@"digest/sha2.so"      init:^{Init_sha2();}];
	//[self addExtension:@"dl/callback"         init:^{Init_callback();}];
	//[self addExtension:@"dl"                  init:^{Init_dl();}];
	[self addExtension:@"etc.so"              init:^{Init_etc();}];
	[self addExtension:@"fcntl"               init:^{Init_fcntl();}];
	[self addExtension:@"fiber"               init:^{Init_fiber();}];
	//[self addExtension:@"fiddle.so"           init:^{Init_fiddle();}];
	[self addExtension:@"io/console"          init:^{Init_console();}];
	[self addExtension:@"io/nonblock"         init:^{Init_nonblock();}];
	[self addExtension:@"io/wait"             init:^{Init_wait();}];
	[self addExtension:@"json/ext/generator"  init:^{Init_generator();}];
	[self addExtension:@"json/ext/parser"     init:^{Init_parser();}];
	[self addExtension:@"nkf"                 init:^{Init_nkf();}];
	[self addExtension:@"objspace"            init:^{Init_objspace();}];
	[self addExtension:@"pathname.so"         init:^{Init_pathname();}];
	[self addExtension:@"psych.so"            init:^{Init_psych();}];
	[self addExtension:@"pty"                 init:^{Init_pty();}];
	[self addExtension:@"racc/cparse"         init:^{Init_cparse();}];
	[self addExtension:@"rbconfig/sizeof"     init:^{Init_sizeof();}];
	//[self addExtension:@"readline"            init:^{Init_readline();}];
	[self addExtension:@"ripper.so"           init:^{Init_ripper();}];
	[self addExtension:@"sdbm"                init:^{Init_sdbm();}];
	[self addExtension:@"socket.so"           init:^{Init_socket();}];
	[self addExtension:@"stringio"            init:^{Init_stringio();}];
	[self addExtension:@"strscan"             init:^{Init_strscan();}];
	//[self addExtension:@"syslog"              init:^{Init_syslog();}];
	[self addExtension:@"zlib"                init:^{Init_zlib();}];
}

@end
