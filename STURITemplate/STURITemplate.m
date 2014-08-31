//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot.

#import "STURITemplate.h"


@implementation STURITemplate {
@private
    NSURL *_baseURL;
}

- (id)init {
    return [self initWithTemplate:nil baseURL:nil];
}
- (id)initWithTemplate:(NSString *)template {
    return [self initWithTemplate:template baseURL:nil];
}
- (id)initWithTemplate:(NSString *)template baseURL:(NSURL *)baseURL {
    if ((self = [super init])) {
        _baseURL = baseURL.copy;
    }
    return self;
}

- (NSURL *)url {
    return [[NSURL alloc] initWithString:@"" relativeToURL:_baseURL];
}

@end
