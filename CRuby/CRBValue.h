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

- (NSInteger     )toInt;
- (NSString     *)toString;
- (NSArray      *)toArray;
- (NSDictionary *)toDictionary;

- (NSString *)inspect;

@end
