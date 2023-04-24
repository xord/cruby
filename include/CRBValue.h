// -*- mode: objc -*-
#import <Foundation/Foundation.h>
#include <ruby.h>


@interface CRBValue : NSObject

typedef void (^RescueBlock) (CRBValue* exception);

@property (nonatomic, readonly) VALUE value;

- (instancetype)initWithVALUE:(VALUE)value;
- (instancetype)initWithNSString:(NSString*)string;

+ (instancetype)valueWithVALUE:(VALUE)value;
+ (instancetype)valueWithNSString:(NSString*)string;

- (CRBValue*)call:(NSString*)method args:(NSArray*)values;
- (CRBValue*)call:(NSString*)method args:(NSArray*)values rescue:(RescueBlock)rescue;

- (CRBValue*)call:(NSString*)method;
- (CRBValue*)call:(NSString*)method rescue:(RescueBlock)rescue;

- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1;
- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1 rescue:(RescueBlock)rescue;

- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1 arg2:(CRBValue*)arg2;
- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1 arg2:(CRBValue*)arg2 rescue:(RescueBlock)rescue;

- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1 arg2:(CRBValue*)arg2 arg3:(CRBValue*)arg3;
- (CRBValue*)call:(NSString*)method arg1:(CRBValue*)arg1 arg2:(CRBValue*)arg2 arg3:(CRBValue*)arg3 rescue:(RescueBlock)rescue;

- (BOOL)isNil;
- (BOOL)isInteger;
- (BOOL)isFloat;
- (BOOL)isString;
- (BOOL)isArray;
- (BOOL)isDictionary;

-                                (BOOL)toBOOL;
-                           (NSInteger)toInteger;
-                              (double)toFloat;
-                           (NSString*)toString;
-                 (NSArray<CRBValue*>*)toArray;
- (NSDictionary<CRBValue*, CRBValue*>*)toDictionary;

- (NSString*)inspect;

@end
