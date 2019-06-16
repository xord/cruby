// -*- mode: objc -*-
#import "CRBValue.h"


@implementation CRBValue
{
	VALUE _value;
}

- (instancetype)initWithValue:(VALUE)value
{
	self = [super init];
	if (self)
	{
		_value = value;
	}
	return self;
}

- (CRBValue *)call:(NSString *)method args:(NSArray *)args
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
			values[i] = ((CRBValue *)args[i]).value;
		ret = rb_funcallv(_value, symbol, (int) args.count, values);
	}

	return [[[CRBValue alloc] initWithValue:ret] autorelease];
}

- (CRBValue *)call:(NSString *)method
{
	return [self call:method args:nil];
}

- (CRBValue *)call:(NSString *)method arg1:(CRBValue *)arg1
{
	return [self call:method args:@[arg1]];
}

- (CRBValue *)call:(NSString *)method arg1:(CRBValue *)arg1 arg2:(CRBValue *)arg2
{
	return [self call:method args:@[arg1, arg2]];
}

- (CRBValue *)call:(NSString *)method arg1:(CRBValue *)arg1 arg2:(CRBValue *)arg2 arg3:(CRBValue *)arg3
{
	return [self call:method args:@[arg1, arg2, arg3]];
}

- (BOOL)toBOOL
{
	return RTEST(_value) ? YES : NO;
}

- (NSInteger)toInt
{
	VALUE i = [self call:@"to_i"].value;
	return FIX2INT(i);
}

- (NSString *)toString
{
	VALUE s = [self call:@"to_s"].value;
	return [NSString stringWithUTF8String:StringValueCStr(s)];
}

- (NSArray *)toArray
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

- (NSDictionary *)toDictionary
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

- (NSString *)inspect
{
	VALUE ret = [self call:@"inspect"].value;
	return [NSString stringWithUTF8String:StringValueCStr(ret)];
}

@end
