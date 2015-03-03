//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot.

#import <Foundation/Foundation.h>


extern NSString * __nonnull const STURITemplateErrorDomain;


@protocol STURITemplate <NSObject>
@property (nonatomic,copy,readonly) NSArray * __nonnull variableNames;
- (NSString * __nonnull)stringByExpandingWithVariables:(NSDictionary * __nullable)variables;
- (NSURL * __nullable)urlByExpandingWithVariables:(NSDictionary * __nullable)variables;
@end

@interface STURITemplate : NSObject<STURITemplate>
- (id __nullable)initWithString:(NSString * __nonnull)string;
- (id __nullable)initWithString:(NSString * __nonnull)string error:(NSError * __autoreleasing __nullable * __nullable)error;
- (NSString * __nonnull)templatedStringRepresentation;
@end
