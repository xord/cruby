// -*- mode: objc -*-
#import "CRBValue.h"


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

- (CRBValue*)call:(NSString*)method args:(NSArray*)args
{
	VALUE ret = Qnil;
	ID symbol = rb_intern(method.UTF8String);

	if (!args || args.count <= 0)
		ret = rb_funcall(_value, symbol, 0);
	else
	{
		enum {MAX = 16};
		if (args.count > MAX) return nil;

		VALUE values[MAX];
		for (NSUInteger i = 0; i < args.count; ++i)
			values[i] = ((CRBValue*) args[i]).value;
		ret = rb_funcallv(_value, symbol, (int) args.count, values);
	}

	return [[[CRBValue alloc] initWithValue:ret] autorelease];
}

- (CRBValue*)call:(NSString*)method
{
	return [self call:method args:nil];
}

- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1
{
	return [self call:method args:@[arg1]];
}

- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1 arg2:(CRBValue*)arg2
{
	return [self call:method args:@[arg1, arg2]];
}

- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1 arg2:(CRBValue*)arg2 arg3:(CRBValue*)arg3
{
	return [self call:method args:@[arg1, arg2, arg3]];
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
		CRBValue* value = [[[CRBValue alloc] initWithValue:RARRAY_AREF(a, i)] autorelease];
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
		CRBValue* key   = [[[CRBValue alloc] initWithValue:RARRAY_AREF(e, 0)] autorelease];
		CRBValue* value = [[[CRBValue alloc] initWithValue:RARRAY_AREF(e, 1)] autorelease];
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
