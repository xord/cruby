// -*- mode: objc -*-
#import "CRuby.h"
#import "CRBValue.h"
#include <ruby.h>


#ifndef TAG_RAISE
	#define TAG_RAISE 0x6
#endif


@implementation CRuby

+ (void)setup {
	static BOOL done = NO;
	if (done) return;
	done = YES;

	ruby_init();

	[self setup_loadpath];
}

+ (void)setup_loadpath {
	NSBundle *bundle  = [NSBundle bundleForClass:CRuby.class];
	NSString *lib_dir = [NSString stringWithFormat:
		#if TARGET_OS_IPHONE
			@"%@/CRuby.bundle/lib", bundle.bundlePath];
		#else
			@"%@/CRuby.bundle/Contents/Resources/lib", bundle.resourcePath];
		#endif
	[self eval:[NSString stringWithFormat:@"$LOAD_PATH << '%@'", lib_dir]];
}

+ (void)cleanup
{
	ruby_finalize();
}

+ (CRBValue *)eval:(NSString *)string {
	return [self eval:string rescue:nil];
}

+ (CRBValue *)eval:(NSString *)string rescue:(void(^)(CRBValue *))rescue
{
	[self setup];
	
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

@end
