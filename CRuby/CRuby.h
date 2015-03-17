// -*- mode: objc -*-
#import <Foundation/Foundation.h>
#import <CRBValue.h>


@interface CRuby : NSObject

typedef void (^RescueBlock) (CRBValue *exception);

+ (BOOL)load:(NSString *)filename;

+ (BOOL)load:(NSString *)filename rescue:(RescueBlock)rescue;

+ (CRBValue *)evaluate:(NSString *)string;

+ (CRBValue *)evaluate:(NSString *)string rescue:(RescueBlock)rescue;

+ (void)addLibrary:(NSString *)name bundle:(NSBundle *)bundle;

+ (void)addExtension:(NSString *)path init:(void(^)())init;

@end
