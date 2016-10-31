//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright © 2014-2016 Scott Talbot.

#import <Foundation/Foundation.h>


extern NSString * __nonnull const STURITemplateErrorDomain;


/**
 * A URI Template ([RFC6570](https://tools.ietf.org/rfc/rfc6570.txt))
 */
@protocol STURITemplate <NSObject>
/**
 * The names of variables referenced in the template, in order of appearance
 */
@property (nonatomic,copy,nonnull,readonly) NSArray<NSString *> *variableNames;
/**
 * Expand a uritemplate to a string, substituting variables from the provided dictionary
 *
 * @param variables NSDictionary of NSString -> NSString, NSNumber or an NSArray of same
 */
- (NSString * __nullable)stringByExpandingWithVariables:(NSDictionary<NSString *, id> * __nullable)variables;
/**
 * Expand a uritemplate to a url, substituting variables from the provided dictionary
 *
 * @param variables NSDictionary of NSString -> NSString, NSNumber or an NSArray of same
 */
- (NSURL * __nullable)urlByExpandingWithVariables:(NSDictionary<NSString *, id> * __nullable)variables;
@end


/**
 * A URI Template ([RFC6570](https://tools.ietf.org/rfc/rfc6570.txt))
 */
@interface STURITemplate : NSObject<STURITemplate>
- (instancetype __null_unspecified)init NS_UNAVAILABLE;
- (instancetype __nullable)initWithString:(NSString * __nonnull)string;
- (instancetype __nullable)initWithString:(NSString * __nonnull)string error:(NSError * __nullable __autoreleasing * __nullable)error NS_DESIGNATED_INITIALIZER;
- (NSString * __nonnull)templatedStringRepresentation;
@end
