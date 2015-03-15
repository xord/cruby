// -*- mode: objc -*-
#import <Foundation/Foundation.h>


#import <CRBValue.h>


@interface CRuby : NSObject

typedef void (^RescueBlock) (CRBValue *exception);

+ (void)load:(NSString *)filename;

+ (void)load:(NSString *)filename rescue:(RescueBlock)rescue;

+ (CRBValue *)eval:(NSString *)string;

+ (CRBValue *)eval:(NSString *)string rescue:(RescueBlock)rescue;

+ (void)addLibrary:(NSString *)name bundle:(NSBundle *)bundle;

+ (void)addExtension:(NSString *)path init:(void(^)())init;

@end
