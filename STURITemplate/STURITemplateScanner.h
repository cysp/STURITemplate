//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014-2015 Scott Talbot.

#import "STURITemplate.h"
#import "STURITemplateInternal.h"


@interface STURITemplateScanner : NSObject
- (instancetype)initWithString:(NSString *)string __attribute__((objc_designated_initializer));
- (BOOL)scanString:(NSString *)string intoString:(NSString * __autoreleasing *)result;
- (BOOL)scanCharactersFromSet:(NSCharacterSet *)set intoString:(NSString **)result;
- (BOOL)scanUpToString:(NSString *)string intoString:(NSString * __autoreleasing *)result;
- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)set intoString:(NSString * __autoreleasing *)result;
@property (nonatomic,assign,getter=isAtEnd,readonly) BOOL atEnd;
- (BOOL)sturit_scanTemplateComponent:(id<STURITemplateComponent> __autoreleasing *)component;
@end
