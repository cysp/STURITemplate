//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import <XCTest/XCTest.h>

@import STURITemplate;


@interface STURITemplateTests : XCTestCase
@end

@implementation STURITemplateTests

+ (void)setUp {
    NSBundle * const bundle = [NSBundle bundleForClass:self];
    NSArray * const testcaseFilenames = @[
        @"spec-examples.json",
        @"negative-tests.json",
        @"extended-tests.json",
    ];
    for (NSString *testcaseFilename in testcaseFilenames) {
        NSURL * const testcaseURL = [bundle URLForResource:testcaseFilename withExtension:nil subdirectory:@"uritemplate-test"];
        NSData * const testcaseData = [[NSData alloc] initWithContentsOfURL:testcaseURL options:NSDataReadingMappedIfSafe error:NULL];
        NSDictionary * const testcaseDict = [NSJSONSerialization JSONObjectWithData:testcaseData options:0 error:NULL];
        if (![testcaseDict isKindOfClass:[NSDictionary class]]) {
            continue;
        }
    }
}

- (void)test1 {
    STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:@"address{?formatted_address}"];
    XCTAssertEqualObjects(t.url.absoluteString, @"");
}
- (void)test2 {
    STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:@"address{?formatted_address}"];
    XCTAssertEqualObjects(t.url.absoluteString, @"");
}

@end
