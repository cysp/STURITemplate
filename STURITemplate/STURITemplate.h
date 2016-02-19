//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#if __has_attribute(ns_error_domain)
# define STURIT_ERROR_ENUM(_type, _name, _domain) enum _name : _type _name; enum __attribute__((ns_error_domain(_domain))) _name : _type
#else
# define STURIT_ERROR_ENUM(_type, _name, _domain) NS_ENUM(_type, _name)
#endif


extern NSString * const STURITemplateErrorDomain;

typedef STURIT_ERROR_ENUM(NSUInteger, STURITemplateError, STURITemplateErrorDomain) {
    STURITemplateUnknownError = 0,
};


@protocol STURITemplate <NSObject>
@property (nonatomic,copy,readonly) NSArray<NSString *> *variableNames;
- (NSString * __nullable)stringByExpandingWithVariables:(NSDictionary<NSString *, id> * __nullable)variables NS_SWIFT_UNAVAILABLE("");
- (NSString * __nullable)stringByExpandingWithVariables:(NSDictionary<NSString *, id> * __nullable)variables error:(NSError * __nullable * __nullable)error NS_SWIFT_NAME(expand(variables:));
- (NSURL * __nullable)urlByExpandingWithVariables:(NSDictionary<NSString *, id> * __nullable)variables NS_SWIFT_UNAVAILABLE("");
- (NSURL * __nullable)urlByExpandingWithVariables:(NSDictionary<NSString *, id> * __nullable)variables error:(NSError * __nullable * __nullable)error NS_SWIFT_NAME(expand(variables:));
@end

@interface STURITemplate : NSObject<STURITemplate>
- (instancetype __nullable)initWithString:(NSString *)string NS_SWIFT_UNAVAILABLE("");
- (instancetype __nullable)initWithString:(NSString *)string error:(NSError * __autoreleasing __nullable * __nullable)error;
- (NSString *)templatedStringRepresentation;
@property (nonatomic,copy,readonly) NSArray<NSString *> *variableNames;
- (NSString * __nullable)stringByExpandingWithVariables:(NSDictionary<NSString *, id> * __nullable)variables NS_SWIFT_UNAVAILABLE("");
- (NSString * __nullable)stringByExpandingWithVariables:(NSDictionary<NSString *, id> * __nullable)variables error:(NSError * __autoreleasing __nullable * __nullable)error NS_SWIFT_NAME(expand(variables:));
- (NSURL * __nullable)urlByExpandingWithVariables:(NSDictionary<NSString *, id> * __nullable)variables NS_SWIFT_UNAVAILABLE("");
- (NSURL * __nullable)urlByExpandingWithVariables:(NSDictionary<NSString *, id> * __nullable)variables error:(NSError * __autoreleasing __nullable * __nullable)error NS_SWIFT_NAME(expand(variables:));
@end

NS_ASSUME_NONNULL_END
