//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


extern NSString * const STURITemplateErrorDomain;


@protocol STURITemplate <NSObject>
@property (nonatomic,copy,readonly) NSArray<NSString *> *variableNames;
- (NSString *)stringByExpandingWithVariables:(NSDictionary<NSString *, NSString *> * __nullable)variables;
- (NSURL * __nullable)urlByExpandingWithVariables:(NSDictionary<NSString *, NSString *> * __nullable)variables;
@end

@interface STURITemplate : NSObject<STURITemplate>
- (instancetype __nullable)initWithString:(NSString *)string NS_SWIFT_UNAVAILABLE("");
- (instancetype __nullable)initWithString:(NSString *)string error:(NSError * __autoreleasing *)error;
- (NSString *)templatedStringRepresentation;
@end

NS_ASSUME_NONNULL_END
