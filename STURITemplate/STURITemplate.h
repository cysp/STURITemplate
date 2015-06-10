//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014-2015 Scott Talbot.

#import <Foundation/Foundation.h>


extern NSString * __nonnull const STURITemplateErrorDomain;


@protocol STURITemplate <NSObject>
@property (nonatomic,copy,readonly) NSArray * __nonnull variableNames;
- (NSString * __nonnull)stringByExpandingWithVariables:(NSDictionary * __nonnull)variables;
- (NSURL * __nullable)urlByExpandingWithVariables:(NSDictionary * __nonnull)variables;
@end

@interface STURITemplate : NSObject<STURITemplate>
- (STURITemplate * __nullable)initWithString:(NSString * __nonnull)string;
- (STURITemplate * __nullable)initWithString:(NSString * __nonnull)string error:(NSError * __nullable __autoreleasing * __nullable)error NS_DESIGNATED_INITIALIZER;
- (NSString * __nonnull)templatedStringRepresentation;
@end
