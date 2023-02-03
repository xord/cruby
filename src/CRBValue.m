// -*- mode: objc -*-
#import "CRBValue.h"


#ifndef TAG_RAISE
	#define TAG_RAISE 0x6
#endif


@implementation CRBValue
{
	VALUE _value;
}

- (instancetype)initWithVALUE:(VALUE)value
{
	self = [super init];
	if (self) _value = value;
	return self;
}

- (instancetype)initWithNSString:(NSString*)string
{
	self = [super init];
	if (self) _value = rb_utf8_str_new_cstr(string.UTF8String);
	return self;
}

+ (instancetype)valueWithVALUE:(VALUE)value
{
	return [[[CRBValue alloc] initWithVALUE:value] autorelease];
}

+ (instancetype)valueWithNSString:(NSString*)string
{
	return [[[CRBValue alloc] initWithNSString:string] autorelease];
}

static VALUE
call (VALUE args)
{
	assert(RARRAY_LEN(args) >= 2);

	VALUE self = rb_ary_shift(args);
	ID method  = rb_intern(RSTRING_PTR(rb_ary_shift(args)));

	if (RARRAY_LEN(args) <= 0)
		return rb_funcall(self, method, 0);
	else
	{
		VALUE ret = Qnil;
		RARRAY_PTR_USE(args, ptr, {
			ret = rb_funcallv(self, method, RARRAY_LENINT(args), ptr);
		});
		return ret;
	}
}

- (CRBValue*)call:(NSString*)method args:(NSArray*)args
{
	return [self call:method args:args rescue:nil];
}

- (CRBValue*)call:(NSString*)method args:(NSArray*)args rescue:(RescueBlock)rescue
{
	NSUInteger argc = args ? args.count : 0;

	VALUE array = rb_ary_new_capa(argc);
	rb_ary_push(array, self.value);
	rb_ary_push(array, [CRBValue valueWithNSString:method].value);

	for (NSUInteger i = 0; i < argc; ++i)
		rb_ary_push(array, ((CRBValue*) args[i]).value);

	int state = 0;
	VALUE ret = rb_protect(call, array, &state);

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

- (CRBValue*)call:(NSString*)method
{
	return [self call:method args:nil rescue:nil];
}

- (CRBValue*)call:(NSString*)method rescue:(RescueBlock)rescue
{
	return [self call:method args:nil rescue:rescue];
}

- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1
{
	return [self call:method args:@[arg1] rescue:nil];
}

- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1 rescue:(RescueBlock)rescue
{
	return [self call:method args:@[arg1] rescue:rescue];
}

- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1 arg2:(CRBValue*)arg2
{
	return [self call:method args:@[arg1, arg2] rescue:nil];
}

- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1 arg2:(CRBValue*)arg2 rescue:(RescueBlock)rescue
{
	return [self call:method args:@[arg1, arg2] rescue:rescue];
}

- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1 arg2:(CRBValue*)arg2 arg3:(CRBValue*)arg3
{
	return [self call:method args:@[arg1, arg2, arg3] rescue:nil];
}

- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1 arg2:(CRBValue*)arg2 arg3:(CRBValue*)arg3 rescue:(RescueBlock)rescue
{
	return [self call:method args:@[arg1, arg2, arg3] rescue:rescue];
}

- (BOOL)isNil
{
	return NIL_P(_value);
}

- (BOOL)isInteger
{
	return FIXNUM_P(_value)      ||
		self.type == RUBY_T_BIGNUM ||
		[self isKindOf:rb_cInteger];
}

- (BOOL)isFloat
{
	return RB_FLOAT_TYPE_P(_value) || [self isKindOf:rb_cFloat];
}

- (BOOL)isString
{
	return SYMBOL_P(_value)      ||
		self.type == RUBY_T_STRING ||
		[self isKindOf:rb_cSymbol] ||
		[self isKindOf:rb_cString];
}

- (BOOL)isArray
{
	return self.type == RUBY_T_ARRAY || [self isKindOf:rb_cArray];
}

- (BOOL)isDictionary
{
	return self.type == RUBY_T_HASH || [self isKindOf:rb_cHash];
}

- (BOOL)isKindOf:(VALUE)type
{
	return rb_obj_is_kind_of(_value, type);
}

- (int)type
{
	return TYPE(_value);
}

- (BOOL)toBOOL
{
	return RTEST(_value) ? YES : NO;
}

- (NSInteger)toInteger
{
	VALUE i = [self call:@"to_i"].value;
	return NUM2INT(i);
}

- (double)toFloat
{
	VALUE f = [self call:@"to_f"].value;
	return RFLOAT_VALUE(f);
}

- (NSString*)toString
{
	VALUE s = [self call:@"to_s"].value;
	return [NSString stringWithUTF8String:StringValueCStr(s)];
}

- (NSArray*)toArray
{
	VALUE a = [self call:@"to_a"].value;
	if (a == Qnil) return nil;

	NSMutableArray* result = [NSMutableArray array];
	for (long i = 0, len = RARRAY_LEN(a); i < len; ++i)
	{
		CRBValue* value = [CRBValue valueWithVALUE:RARRAY_AREF(a, i)];
		[result addObject:value];
	}
	return result;
}

- (NSDictionary*)toDictionary
{
	VALUE a = [self call:@"to_a"].value;
	if (a == Qnil) return nil;

	NSMutableDictionary* result = [NSMutableDictionary dictionary];
	for (long i = 0, len = RARRAY_LEN(a); i < len; ++i)
	{
		VALUE e = RARRAY_AREF(a, i);
		CRBValue* key   = [CRBValue valueWithVALUE:RARRAY_AREF(e, 0)];
		CRBValue* value = [CRBValue valueWithVALUE:RARRAY_AREF(e, 1)];
		[result setObject:value forKey:[key toString]];
	}
	return result;
}

- (NSString*)inspect
{
	VALUE ret = [self call:@"inspect"].value;
	return [NSString stringWithUTF8String:StringValueCStr(ret)];
}

@end
