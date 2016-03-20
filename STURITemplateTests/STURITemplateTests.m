//  Copyright (c) 2014 Scott Talbot. All rights reserved.

#import <XCTest/XCTest.h>

#import "STURITemplate.h"


@interface STURITemplateTests : XCTestCase
@end

@implementation STURITemplateTests

- (void)test1 {
    STURITemplate * const t = [[STURITemplate alloc] initWithString:@"address{?formatted_address}"];
    XCTAssertEqualObjects(t.templatedStringRepresentation, @"address{?formatted_address}");
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
    STURITemplate * const t = [[STURITemplate alloc] initWithString:@"address{/id}"];
    XCTAssertEqualObjects(t.templatedStringRepresentation, @"address{/id}");
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
    STURITemplate * const t = [[STURITemplate alloc] initWithString:@"foo/bar/baz"];
    XCTAssertEqualObjects(t.templatedStringRepresentation, @"foo/bar/baz");
    {
        NSURL * const u = [t urlByExpandingWithVariables:nil];
        XCTAssertEqualObjects(u.absoluteString, @"foo/bar/baz");
    }
}
- (void)test4 {
    STURITemplate * const t = [[STURITemplate alloc] initWithString:@"foo/bar%20bar/baz"];
    XCTAssertEqualObjects(t.templatedStringRepresentation, @"foo/bar%20bar/baz");
    {
        NSURL * const u = [t urlByExpandingWithVariables:nil];
        XCTAssertEqualObjects(u.absoluteString, @"foo/bar%20bar/baz");
    }
}
- (void)test5 {
    STURITemplate * const t = [[STURITemplate alloc] initWithString:@"gr%C3%BCner%20weg"];
    XCTAssertEqualObjects(t.templatedStringRepresentation, @"gr%C3%BCner%20weg");
    {
        NSURL * const u = [t urlByExpandingWithVariables:nil];
        XCTAssertEqualObjects(u.absoluteString, @"gr%C3%BCner%20weg");
    }
}
- (void)test6 {
    NSString * const s = @"https://example.org/api/info/sports/Basketball/competitions/College%20Basketball/matches/2014%2F15%20NCAA%20Basketball?jurisdiction=nsw";
    STURITemplate * const t = [[STURITemplate alloc] initWithString:s];
    XCTAssertEqualObjects(t.templatedStringRepresentation, s);
    XCTAssertEqualObjects([t urlByExpandingWithVariables:nil].absoluteString, s);
}
- (void)test7 {
    NSString * const s = @"https://example.org/api/info/search/propositions{?proposition_id*}";
    STURITemplate * const t = [[STURITemplate alloc] initWithString:s];
    XCTAssertEqualObjects(t.templatedStringRepresentation, s);
    {
        NSURL * const u = [t urlByExpandingWithVariables:nil];
        XCTAssertEqualObjects(u.absoluteString, @"https://example.org/api/info/search/propositions");
    }
    {
        NSURL * const u = [t urlByExpandingWithVariables:@{
            @"proposition_id": @"1",
        }];
        XCTAssertEqualObjects(u.absoluteString, @"https://example.org/api/info/search/propositions?proposition_id=1");
    }
    {
        NSURL * const u = [t urlByExpandingWithVariables:@{
            @"proposition_id": @1,
        }];
        XCTAssertEqualObjects(u.absoluteString, @"https://example.org/api/info/search/propositions?proposition_id=1");
    }
    {
        NSURL * const u = [t urlByExpandingWithVariables:@{
            @"proposition_id": @[ @"1", @"2" ],
        }];
        XCTAssertEqualObjects(u.absoluteString, @"https://example.org/api/info/search/propositions?proposition_id=1&proposition_id=2");
    }
    {
        NSURL * const u = [t urlByExpandingWithVariables:@{
            @"proposition_id": @[ @1, @2 ],
        }];
        XCTAssertEqualObjects(u.absoluteString, @"https://example.org/api/info/search/propositions?proposition_id=1&proposition_id=2");
    }
}


- (void)testNegative {
    NSDictionary * const variables = @{
        @"id"                : @"thing",
        @"var"               : @"value",
        @"hello"             : @"Hello World!",
        @"with space"        : @"fail",
        @" leading_space"    : @"Hi!",
        @"trailing_space "   : @"Bye!",
        @"empty"             : @"",
        @"path"              : @"/foo/bar",
        @"x"                 : @"1024",
        @"y"                 : @"768",
        @"list"              : @[@"red", @"green", @"blue"],
        @"keys"              : @{ @"semi" : @";", @"dot" : @".", @"comma" : @","},
        @"example"           : @"red",
        @"searchTerms"       : @"uri templates",
        @"~thing"            : @"some-user",
        @"default-graph-uri" : @[@"http://www.example/book/",@"http://www.example/papers/"],
        @"query"             : @"PREFIX dc: <http://purl.org/dc/elements/1.1/> SELECT ?book ?who WHERE { ?book dc:creator ?who }"
    };

    {
        NSString * const input = @"{/id*";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"/id*}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{/?id}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{var:prefix}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{hello:2*}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{??hello}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{!hello}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{with space}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{ leading_space}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{trailing_space }";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{=path}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{$var}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{|var*}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{*keys?}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{?empty=default,var}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{var}{-prefix|/-/|var}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"?q={searchTerms}&amp;c={example:color?}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"x{?empty|foo=none}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"/h{#hello+}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"/h#{hello+}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"{keys:1}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNotNil(t);
        NSURL * const u = [t urlByExpandingWithVariables:variables];
        XCTAssertNil(u);
    }
    {
        NSString * const input = @"{+keys:1}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNotNil(t);
        NSURL * const u = [t urlByExpandingWithVariables:variables];
        XCTAssertNil(u);
    }
    {
        NSString * const input = @"{;keys:1*}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"?{-join|&|var,list}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"/people/{~thing}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"/{default-graph-uri}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"/sparql{?query,default-graph-uri}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"/sparql{?query){&default-graph-uri*}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
    }
    {
        NSString * const input = @"/resolution{?x, y}";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertNil(t);
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
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{hello}";
        NSString * const expected = @"Hello%20World%21";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
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
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{+hello}";
        NSString * const expected = @"Hello%20World!";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{+path}/here";
        NSString * const expected = @"/foo/bar/here";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"here?ref={+path}";
        NSString * const expected = @"here?ref=/foo/bar";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
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
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{x,hello,y}";
        NSString * const expected = @"1024,Hello%20World%21,768";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{+x,hello,y}";
        NSString * const expected = @"1024,Hello%20World!,768";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{+path,x}/here";
        NSString * const expected = @"/foo/bar,1024/here";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{#x,hello,y}";
        NSString * const expected = @"#1024,Hello%20World!,768";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{#path,x}/here";
        NSString * const expected = @"#/foo/bar,1024/here";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"X{.var}";
        NSString * const expected = @"X.value";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"X{.x,y}";
        NSString * const expected = @"X.1024.768";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{/var}";
        NSString * const expected = @"/value";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{/var,x}/here";
        NSString * const expected = @"/value/1024/here";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{;x,y}";
        NSString * const expected = @";x=1024;y=768";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{;x,y,empty}";
        NSString * const expected = @";x=1024;y=768;empty";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{?x,y}";
        NSString * const expected = @"?x=1024&y=768";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{?x,y,empty}";
        NSString * const expected = @"?x=1024&y=768&empty=";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"?fixed=yes{&x}";
        NSString * const expected = @"?fixed=yes&x=1024";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{&x,y,empty}";
        NSString * const expected = @"&x=1024&y=768&empty=";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
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

    if (0) {
        NSString * const input = @"/{id*}";
        NSString * const expected = @"/person";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
//        NSString * const input = @"{/id*}{?fields,first_name,last.name,token}";
        NSString * const input = @"{?fields,first_name,last.name,token}";
        NSArray * const expected = @[
            @"?fields=id,name,picture&first_name=John&last.name=Doe&token=12345",
            @"?fields=id,picture,name&first_name=John&last.name=Doe&token=12345",
            @"?fields=picture,name,id&first_name=John&last.name=Doe&token=12345",
            @"?fields=picture,id,name&first_name=John&last.name=Doe&token=12345",
            @"?fields=name,picture,id&first_name=John&last.name=Doe&token=12345",
            @"?fields=name,id,picture&first_name=John&last.name=Doe&token=12345",
        ];
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        NSString * const output = [t urlByExpandingWithVariables:variables].absoluteString;
        XCTAssert([expected containsObject:output]);
    }

    {
        NSString * const input = @"/search.{format}{?q,geocode,lang,locale,page,result_type}";
        NSArray * const expected = @[
            @"/search.json?q=URI%20Templates&geocode=37.76,-122.427&lang=en&page=5",
            @"/search.json?q=URI%20Templates&geocode=-122.427,37.76&lang=en&page=5",
        ];
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        NSString * const output = [t urlByExpandingWithVariables:variables].absoluteString;
        XCTAssert([expected containsObject:output]);
    }

    {
        NSString * const input = @"/test{/Some%20Thing}";
        NSString * const expected = @"/test/foo";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"/set{?number}";
        NSString * const expected = @"/set?number=6";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"/loc{?long,lat}";
        NSString * const expected = @"/loc?long=37.76&lat=-122.427";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"/base{/group_id,first_name}/pages{/page,lang}{?format,q}";
        NSString * const expected = @"/base/12345/John/pages/5/en?format=json&q=URI%20Templates";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"/sparql{?query}";
        NSString * const expected = @"/sparql?query=PREFIX%20dc%3A%20%3Chttp%3A%2F%2Fpurl.org%2Fdc%2Felements%2F1.1%2F%3E%20SELECT%20%3Fbook%20%3Fwho%20WHERE%20%7B%20%3Fbook%20dc%3Acreator%20%3Fwho%20%7D";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"/go{?uri}";
        NSString * const expected = @"/go?uri=http%3A%2F%2Fexample.org%2F%3Furi%3Dhttp%253A%252F%252Fexample.org%252F";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"/service{?word}";
        NSString * const expected = @"/service?word=dr%C3%BCcken";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"/lookup{?Stra%C3%9Fe}";
        NSString * const expected = @"/lookup?Stra%C3%9Fe=Gr%C3%BCner%20Weg";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    {
        NSString * const input = @"{random}";
        NSString * const expected = @"%C5%A1%C3%B6%C3%A4%C5%B8%C5%93%C3%B1%C3%AA%E2%82%AC%C2%A3%C2%A5%E2%80%A1%C3%91%C3%92%C3%93%C3%94%C3%95%C3%96%C3%97%C3%98%C3%99%C3%9A%C3%A0%C3%A1%C3%A2%C3%A3%C3%A4%C3%A5%C3%A6%C3%A7%C3%BF";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }

    if (0) {
        NSString * const input = @"{?assoc_special_chars*}";
        NSString * const expected = @"?%C5%A1%C3%B6%C3%A4%C5%B8%C5%93%C3%B1%C3%AA%E2%82%AC%C2%A3%C2%A5%E2%80%A1%C3%91%C3%92%C3%93%C3%94%C3%95=%C3%96%C3%97%C3%98%C3%99%C3%9A%C3%A0%C3%A1%C3%A2%C3%A3%C3%A4%C3%A5%C3%A6%C3%A7%C3%BF";
        STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
        XCTAssertEqualObjects(t.templatedStringRepresentation, input);
        XCTAssertEqualObjects([t urlByExpandingWithVariables:variables].absoluteString, expected);
    }
}


#if defined(__IPHONE_8_0)
- (void)testPerformance {
    NSString * const input = @"https://webapi.tab.com.au/v1/tab-info-service/racing/dates/{meetingDate}/meetings/{raceType}/{venueMnemonic}/races/{raceNumber}/form?jurisdiction={jurisdiction}";

    if ([self respondsToSelector:@selector(measureBlock:)]) {
        [self measureBlock:^{
            for (int i = 0; i < 1000; ++i) {
                STURITemplate * const t = [[STURITemplate alloc] initWithString:input];
                (void)t;
            }
        }];
    }
}
#endif

@end
