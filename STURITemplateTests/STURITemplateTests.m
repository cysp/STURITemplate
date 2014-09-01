//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import <XCTest/XCTest.h>

@import STURITemplate;


@interface STURITemplateTests : XCTestCase
@end

@implementation STURITemplateTests

//+ (XCTestSuite *)defaultTestSuite {
//    XCTestSuite * const defaultTestSuite = [XCTestSuite testSuiteWithName:@"STURITemplateTests"];
//
////    NSBundle * const bundle = [NSBundle bundleForClass:[STURITemplateTest class]];
////    NSArray * const testcaseFilenames = @[
////        @"spec-examples-by-section.json",
////        @"negative-tests.json",
////        @"extended-tests.json",
////    ];
////
////
////    for (NSString *testcaseFilename in testcaseFilenames) {
////        NSURL * const testcaseURL = [bundle URLForResource:testcaseFilename withExtension:nil subdirectory:@"uritemplate-test"];
////        NSData * const testcaseData = [[NSData alloc] initWithContentsOfURL:testcaseURL options:NSDataReadingMappedIfSafe error:NULL];
////        NSDictionary * const testcaseDict = [NSJSONSerialization JSONObjectWithData:testcaseData options:(NSJSONReadingOptions)0 error:NULL];
////        if (![testcaseDict isKindOfClass:[NSDictionary class]]) {
////            continue;
////        }
////
////        XCTestSuite * const suite = [XCTestSuite testSuiteWithName:testcaseFilename];
////        for (NSString *section in testcaseDict.allKeys) {
////            STURITemplateTestSectionSuite * const sectionSuite = [[STURITemplateTestSectionSuite alloc] initWithName:section dictionary:testcaseDict[section]];
////            [suite addTest:sectionSuite];
////        }
////
////        [defaultTestSuite addTest:suite];
////    }
//
//    return defaultTestSuite;
//}

- (void)test1 {
    STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:@"address{?formatted_address}"];
    {
        NSURL * const u = [t urlByExpandingWithVariables:nil];
        XCTAssertEqualObjects(u.absoluteString, @"address");
    }
    {
        NSURL * const u = [t urlByExpandingWithVariables:@{ @"formatted_address": @"105 Campbell St" }];
        XCTAssertEqualObjects(u.absoluteString, @"address?formatted_address=105%20Campbell%20St");
    }
}
- (void)test2 {
    STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:@"address{/id}"];
    {
        NSURL * const u = [t urlByExpandingWithVariables:nil];
        XCTAssertEqualObjects(u.absoluteString, @"address");
    }
    {
        NSURL * const u = [t urlByExpandingWithVariables:@{ @"id": @"abc-def" }];
        XCTAssertEqualObjects(u.absoluteString, @"address/abc-def");
    }
}
- (void)test3 {
    STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:@"foo/bar/baz"];
    {
        NSURL * const u = [t urlByExpandingWithVariables:nil];
        XCTAssertEqualObjects(u.absoluteString, @"foo/bar/baz");
    }

}

- (void)testSpecExamplesLevel1 {
    NSDictionary * const variables = @{
        @"var": @"value",
        @"hello": @"Hello World!",
    };

    {
        NSString * const input = @"{var}";
        NSString * const expected = @"value";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{hello}";
        NSString * const expected = @"Hello%20World%21";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }
}

- (void)testSpecExamplesLevel2 {
    NSDictionary * const variables = @{
        @"var": @"value",
        @"hello": @"Hello World!",
        @"path" : @"/foo/bar",
    };

    {
        NSString * const input = @"{+var}";
        NSString * const expected = @"value";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{+hello}";
        NSString * const expected = @"Hello%20World!";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{+path}/here";
        NSString * const expected = @"/foo/bar/here";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"here?ref={+path}";
        NSString * const expected = @"here?ref=/foo/bar";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }
}

- (void)testSpecExamplesLevel3 {
    NSDictionary * const variables = @{
        @"var": @"value",
        @"hello": @"Hello World!",
        @"empty": @"",
        @"path" : @"/foo/bar",
        @"x": @"1024",
        @"y": @"768",
    };

    {
        NSString * const input = @"map?{x,y}";
        NSString * const expected = @"map?1024,768";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{x,hello,y}";
        NSString * const expected = @"1024,Hello%20World%21,768";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{+x,hello,y}";
        NSString * const expected = @"1024,Hello%20World!,768";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{+path,x}/here";
        NSString * const expected = @"/foo/bar,1024/here";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{#x,hello,y}";
        NSString * const expected = @"#1024,Hello%20World!,768";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{#path,x}/here";
        NSString * const expected = @"#/foo/bar,1024/here";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"X{.var}";
        NSString * const expected = @"X.value";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"X{.x,y}";
        NSString * const expected = @"X.1024.768";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{/var}";
        NSString * const expected = @"/value";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{/var,x}/here";
        NSString * const expected = @"/value/1024/here";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{;x,y}";
        NSString * const expected = @";x=1024;y=768";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{;x,y,empty}";
        NSString * const expected = @";x=1024;y=768;empty";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{?x,y}";
        NSString * const expected = @"?x=1024&y=768";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{?x,y,empty}";
        NSString * const expected = @"?x=1024&y=768&empty=";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"?fixed=yes{&x}";
        NSString * const expected = @"?fixed=yes&x=1024";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{&x,y,empty}";
        NSString * const expected = @"&x=1024&y=768&empty=";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }
}

- (void)testExtended1 {
    NSDictionary * const variables = @{
        @"id"           : @"person",
        @"token"        : @"12345",
        @"fields"       : @[ @"id", @"name", @"picture" ],
        @"format"       : @"json",
        @"q"            : @"URI Templates",
        @"page"         : @"5",
        @"lang"         : @"en",
        @"geocode"      : @[ @"37.76",@"-122.427" ],
        @"first_name"   : @"John",
        @"last.name"    : @"Doe",
        @"Some%20Thing" : @"foo",
        @"number"       : @6,
        @"long"         : @37.76,
        @"lat"          : @-122.427,
        @"group_id"     : @"12345",
        @"query"        : @"PREFIX dc: <http://purl.org/dc/elements/1.1/> SELECT ?book ?who WHERE { ?book dc:creator ?who }",
        @"uri"          : @"http://example.org/?uri=http%3A%2F%2Fexample.org%2F",
        @"word"         : @"drücken",
        @"Stra%C3%9Fe"  : @"Grüner Weg",
        @"random"       : @"šöäŸœñê€£¥‡ÑÒÓÔÕÖ×ØÙÚàáâãäåæçÿ",
        @"assoc_special_chars": @{ @"šöäŸœñê€£¥‡ÑÒÓÔÕ": @"Ö×ØÙÚàáâãäåæçÿ" }
    };

    {
        NSString * const input = @"/{id*}";
        NSString * const expected = @"/person";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{/id*}{?fields,first_name,last.name,token}";
        NSArray * const expected = @[
            @"/person?fields=id,name,picture&first_name=John&last.name=Doe&token=12345",
            @"/person?fields=id,picture,name&first_name=John&last.name=Doe&token=12345",
            @"/person?fields=picture,name,id&first_name=John&last.name=Doe&token=12345",
            @"/person?fields=picture,id,name&first_name=John&last.name=Doe&token=12345",
            @"/person?fields=name,picture,id&first_name=John&last.name=Doe&token=12345",
            @"/person?fields=name,id,picture&first_name=John&last.name=Doe&token=12345",
        ];
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssert([expected containsObject:[t urlByExpandingWithVariables:variables].absoluteString]);
    }

    {
        NSString * const input = @"/search.{format}{?q,geocode,lang,locale,page,result_type}";
        NSArray * const expected = @[
            @"/search.json?q=URI%20Templates&geocode=37.76,-122.427&lang=en&page=5",
            @"/search.json?q=URI%20Templates&geocode=-122.427,37.76&lang=en&page=5",
        ];
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssert([expected containsObject:[t urlByExpandingWithVariables:variables].absoluteString]);
    }

    {
        NSString * const input = @"/test{/Some%20Thing}";
        NSString * const expected = @"/test/foo";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"/set{?number}";
        NSString * const expected = @"/set?number=6";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"/loc{?long,lat}";
        NSString * const expected = @"/loc?long=37.76&lat=-122.427";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"/base{/group_id,first_name}/pages{/page,lang}{?format,q}";
        NSString * const expected = @"/base/12345/John/pages/5/en?format=json&q=URI%20Templates";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"/sparql{?query}";
        NSString * const expected = @"/sparql?query=PREFIX%20dc%3A%20%3Chttp%3A%2F%2Fpurl.org%2Fdc%2Felements%2F1.1%2F%3E%20SELECT%20%3Fbook%20%3Fwho%20WHERE%20%7B%20%3Fbook%20dc%3Acreator%20%3Fwho%20%7D";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"/go{?uri}";
        NSString * const expected = @"/go?uri=http%3A%2F%2Fexample.org%2F%3Furi%3Dhttp%253A%252F%252Fexample.org%252F";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"/service{?word}";
        NSString * const expected = @"/service?word=dr%C3%BCcken";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"/lookup{?Stra%C3%9Fe}";
        NSString * const expected = @"/lookup?Stra%C3%9Fe=Gr%C3%BCner%20Weg";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{random}";
        NSString * const expected = @"%C5%A1%C3%B6%C3%A4%C5%B8%C5%93%C3%B1%C3%AA%E2%82%AC%C2%A3%C2%A5%E2%80%A1%C3%91%C3%92%C3%93%C3%94%C3%95%C3%96%C3%97%C3%98%C3%99%C3%9A%C3%A0%C3%A1%C3%A2%C3%A3%C3%A4%C3%A5%C3%A6%C3%A7%C3%BF";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{?assoc_special_chars*}";
        NSString * const expected = @"?%C5%A1%C3%B6%C3%A4%C5%B8%C5%93%C3%B1%C3%AA%E2%82%AC%C2%A3%C2%A5%E2%80%A1%C3%91%C3%92%C3%93%C3%94%C3%95=%C3%96%C3%97%C3%98%C3%99%C3%9A%C3%A0%C3%A1%C3%A2%C3%A3%C3%A4%C3%A5%C3%A6%C3%A7%C3%BF";
        STURITemplate * const t = [[STURITemplate alloc] initWithTemplate:input];
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }
}

@end
