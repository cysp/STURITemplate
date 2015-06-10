//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014-2015 Scott Talbot.

#import "STURITemplateScanner.h"


static NSCharacterSet *STURITemplateScannerHexCharacterSet = nil;
static NSCharacterSet *STURITemplateScannerLiteralComponentCharacterSet = nil;
static NSCharacterSet *STURITemplateScannerOperatorCharacterSet = nil;
static NSCharacterSet *STURITemplateScannerVariableNameCharacterSet = nil;
static NSCharacterSet *STURITemplateScannerVariableNameMinusDotCharacterSet = nil;


__attribute__((constructor))
static void STURITemplateScannerInit(void) {
    STURITemplateScannerHexCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"];

    {
        NSMutableCharacterSet *cs = [[[NSCharacterSet illegalCharacterSet] invertedSet] mutableCopy];
        [cs formIntersectionWithCharacterSet:[[NSCharacterSet controlCharacterSet] invertedSet]];
        [cs formIntersectionWithCharacterSet:[[NSCharacterSet characterSetWithCharactersInString:@" \"'%<>\\^`{|}"] invertedSet]];
        STURITemplateScannerLiteralComponentCharacterSet = cs.copy;
    }

    STURITemplateScannerOperatorCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"+#./;?&=,!@|"];

    {
        NSMutableCharacterSet *cs = [[NSMutableCharacterSet alloc] init];
        [cs addCharactersInString:@"abcdefghijklmnopqrstuvwxyz"];
        [cs addCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        [cs addCharactersInString:@"0123456789"];
        [cs addCharactersInString:@"_%"];
        STURITemplateScannerVariableNameMinusDotCharacterSet = cs.copy;

        [cs addCharactersInString:@"."];
        STURITemplateScannerVariableNameCharacterSet = cs.copy;
    }
}


@implementation STURITemplateScanner {
@private
    NSScanner *_scanner;
}

- (instancetype)init {
    return [self initWithString:nil];
}

- (instancetype)initWithString:(NSString *)string {
    NSScanner * const scanner = [[NSScanner alloc] initWithString:string];
    if (!scanner) {
        return nil;
    }
    scanner.charactersToBeSkipped = nil;
    if ((self = [super init])) {
        _scanner = scanner;
    }
    return self;
}

- (BOOL)scanString:(NSString *)string intoString:(NSString * __autoreleasing *)result {
    return [_scanner scanString:string intoString:result];
}

- (BOOL)scanCharactersFromSet:(NSCharacterSet *)set intoString:(NSString **)result {
    return [_scanner scanCharactersFromSet:set intoString:result];
}

- (BOOL)scanUpToString:(NSString *)string intoString:(NSString * __autoreleasing *)result {
    return [_scanner scanUpToString:string intoString:result];
}

- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)set intoString:(NSString * __autoreleasing *)result {
    return [_scanner scanUpToCharactersFromSet:set intoString:result];
}

- (BOOL)isAtEnd {
    return [_scanner isAtEnd];
}

- (NSString *)sturit_peekStringUpToLength:(NSUInteger)length {
    NSString * const string = _scanner.string;
    NSUInteger const scanLocation = _scanner.scanLocation;

    NSRange range = (NSRange){
        .location = scanLocation,
    };
    range.length = MIN(length, string.length - range.location);
    return [string substringWithRange:range];
}

- (BOOL)sturit_scanPercentEncoded:(NSString * __autoreleasing *)result {
    NSUInteger const scanLocation = _scanner.scanLocation;

    NSMutableString * const string = @"%".mutableCopy;

    if (![_scanner scanString:@"%" intoString:NULL]) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }

    NSString * const candidateString = [self sturit_peekStringUpToLength:2];
    if (candidateString.length != 2) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }
    unichar candidateCharacters[2] = { 0 };
    [candidateString getCharacters:candidateCharacters range:(NSRange){ .length = 2 }];

    if (![STURITemplateScannerHexCharacterSet characterIsMember:candidateCharacters[0]]) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }
    if (![STURITemplateScannerHexCharacterSet characterIsMember:candidateCharacters[1]]) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }

    if (![_scanner scanString:candidateString intoString:NULL]) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }
    [string appendString:candidateString];

    if (result) {
        *result = string.copy;
    }
    return YES;
}

- (BOOL)sturit_scanLiteralComponent:(id<STURITemplateComponent> __autoreleasing *)result {
    NSUInteger const scanLocation = _scanner.scanLocation;

    NSMutableString * const string = [NSMutableString string];
    while (![_scanner isAtEnd]) {
        BOOL didSomething = NO;
        NSString *scratch = nil;

        if ([_scanner scanCharactersFromSet:STURITemplateScannerLiteralComponentCharacterSet intoString:&scratch]) {
            [string appendString:scratch];
            didSomething = YES;
        } else if ([self sturit_scanPercentEncoded:&scratch]) {
            [string appendString:scratch];
            didSomething = YES;
        }

        if (!didSomething) {
            break;
        }
    }

    if (!string.length) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }

    STURITemplateLiteralComponent * const literalComponent = [[STURITemplateLiteralComponent alloc] initWithString:string];
    if (!literalComponent) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }

    if (result) {
        *result = literalComponent;
    }
    return YES;
}

- (BOOL)sturit_scanVariableName:(NSString * __autoreleasing *)result {
    NSUInteger const scanLocation = _scanner.scanLocation;

    NSMutableString * const string = [[NSMutableString alloc] init];

    {
        NSString *scratch = nil;
        if ([_scanner scanCharactersFromSet:STURITemplateScannerVariableNameMinusDotCharacterSet intoString:&scratch]) {
            [string appendString:scratch];
        }
    }
    if (string.length == 0) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }

    {
        NSString *scratch = nil;
        if ([_scanner scanCharactersFromSet:STURITemplateScannerVariableNameCharacterSet intoString:&scratch]) {
            [string appendString:scratch];
        }
    }

    if (result) {
        *result = string.copy;
    }
    return YES;
}

- (BOOL)sturit_scanVariableSpecification:(STURITemplateComponentVariable * __autoreleasing *)result {
    NSUInteger const scanLocation = _scanner.scanLocation;

    NSString *name = nil;
    if (![self sturit_scanVariableName:&name]) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }

    long long prefixLength = 0;
    if ([_scanner scanString:@":" intoString:NULL]) {
        if (![_scanner scanLongLong:&prefixLength]) {
            [_scanner setScanLocation:scanLocation];
            return NO;
        }
        if (prefixLength < 0 || prefixLength >= 10000) {
            [_scanner setScanLocation:scanLocation];
            return NO;
        }
        STURITemplateComponentVariable * const variable = [[STURITemplateComponentTruncatedVariable alloc] initWithName:name length:(NSUInteger)prefixLength];
        if (result) {
            *result = variable;
        }
        return YES;
    }
    if ([_scanner scanString:@"*" intoString:NULL]) {
        STURITemplateComponentVariable * const variable = [[STURITemplateComponentExplodedVariable alloc] initWithName:name];
        if (result) {
            *result = variable;
        }
        return YES;
    }

    STURITemplateComponentVariable * const variable = [[STURITemplateComponentVariable alloc] initWithName:name];
    if (result) {
        *result = variable;
    }

    return YES;
}

- (BOOL)sturit_scanVariableComponent:(id<STURITemplateComponent> __autoreleasing *)result {
    NSUInteger const scanLocation = _scanner.scanLocation;

    if (![_scanner scanString:@"{" intoString:NULL]) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }

    NSString *operator = nil;
    {
        NSString * const candidateOperator = [self sturit_peekStringUpToLength:1];
        if (candidateOperator.length == 1 && [STURITemplateScannerOperatorCharacterSet characterIsMember:[candidateOperator characterAtIndex:0]]) {
            if (![_scanner scanString:candidateOperator intoString:&operator]) {
                [_scanner setScanLocation:scanLocation];
                return NO;
            }
        }
    }

    NSMutableArray * const variables = [[NSMutableArray alloc] init];
    while (1) {
        STURITemplateComponentVariable *variable = nil;
        if (![self sturit_scanVariableSpecification:&variable]) {
            [_scanner setScanLocation:scanLocation];
            return NO;
        }
        [variables addObject:variable];
        if (![_scanner scanString:@"," intoString:NULL]) {
            break;
        }
    }

    if (![_scanner scanString:@"}" intoString:NULL]) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }

    id<STURITemplateComponent> component = nil;
    if (operator.length > 0) {
        switch ([operator characterAtIndex:0]) {
            case '+':
                component = [[STURITemplateReservedCharacterComponent alloc] initWithVariables:variables];
                break;
            case '#':
                component = [[STURITemplateFragmentComponent alloc] initWithVariables:variables];
                break;
            case '.':
                component = [[STURITemplatePathExtensionComponent alloc] initWithVariables:variables];
                break;
            case '/':
                component = [[STURITemplatePathSegmentComponent alloc] initWithVariables:variables];
                break;
            case ';':
                component = [[STURITemplatePathParameterComponent alloc] initWithVariables:variables];
                break;
            case '?':
                component = [[STURITemplateQueryComponent alloc] initWithVariables:variables];
                break;
            case '&':
                component = [[STURITemplateQueryContinuationComponent alloc] initWithVariables:variables];
                break;
        }
        if (!component) {
            [_scanner setScanLocation:scanLocation];
            return NO;
        }
    }

    if (!component) {
        component = [[STURITemplateSimpleComponent alloc] initWithVariables:variables];
    }

    if (!component) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }

    if (result) {
        *result = component;
    }
    return YES;
}

- (BOOL)sturit_scanTemplateComponent:(id<STURITemplateComponent> __autoreleasing *)result {
    NSUInteger const scanLocation = _scanner.scanLocation;

    if ([self sturit_scanVariableComponent:result]) {
        return YES;
    }

    if ([self sturit_scanLiteralComponent:result]) {
        return YES;
    }
    
    [_scanner setScanLocation:scanLocation];
    return NO;
}

@end
