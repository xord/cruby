// -*- mode: objc -*-
#import <Foundation/Foundation.h>
#include <ruby.h>


@interface CRBValue : NSObject

@property (nonatomic, readonly) VALUE value;

- (instancetype)initWithValue:(VALUE)value;

- (CRBValue *)call:(NSString *)method args:(NSArray *)values;
- (CRBValue *)call:(NSString *)method;
- (CRBValue *)call:(NSString *)method arg1:(CRBValue *)arg1;
- (CRBValue *)call:(NSString *)method arg1:(CRBValue *)arg1 arg2:(CRBValue *)arg2;
- (CRBValue *)call:(NSString *)method arg1:(CRBValue *)arg1 arg2:(CRBValue *)arg2 arg3:(CRBValue *)arg3;

- (BOOL)isNil;
- (BOOL)isInteger;
- (BOOL)isFloat;
- (BOOL)isString;
- (BOOL)isArray;
- (BOOL)isDictionary;

- (BOOL          )toBOOL;
- (NSInteger     )toInteger;
- (double        )toFloat;
- (NSString     *)toString;
- (NSArray      *)toArray;
- (NSDictionary *)toDictionary;

- (NSString *)inspect;

@end
