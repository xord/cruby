// -*- mode: objc -*-
#import <Foundation/Foundation.h>


#import <CRBValue.h>


@interface CRuby : NSObject

+ (CRBValue *)eval:(NSString *)string;

+ (CRBValue *)eval:(NSString *)string rescue:(void(^)(CRBValue *))rescue;

@end
