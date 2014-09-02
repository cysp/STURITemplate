//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot.

#import "STURITemplate.h"


typedef id(^STArrayMapBlock)(id o);
@interface NSArray (STURITemplate)
- (NSArray *)sturi_map:(STArrayMapBlock)block;
@end
@implementation NSArray (STURITemplate)
- (NSArray *)sturi_map:(STArrayMapBlock)block {
    NSMutableArray * const array = [[NSMutableArray alloc] initWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id mappedObject = block(obj);
        if (mappedObject) {
            [array addObject:mappedObject];
        }
    }];
    return array;
}
@end


@protocol STURITemplateComponent <NSObject>
@property (nonatomic,copy,readonly) NSArray *variableNames;
- (NSString *)stringWithVariables:(NSDictionary *)variables;
@end

@interface STURITemplateLiteralComponent : NSObject<STURITemplateComponent>
- (id)initWithString:(NSString *)string;
@end

@interface STURITemplateVariableComponent : NSObject
- (id)initWithVariables:(NSArray *)variables __attribute__((objc_designated_initializer));
@end

@interface STURITemplateSimpleComponent : STURITemplateVariableComponent<STURITemplateComponent>
@end

@interface STURITemplateReservedCharacterComponent : STURITemplateVariableComponent<STURITemplateComponent>
@end

@interface STURITemplateFragmentComponent : STURITemplateVariableComponent<STURITemplateComponent>
@end

@interface STURITemplatePathSegmentComponent : STURITemplateVariableComponent<STURITemplateComponent>
@end

@interface STURITemplatePathExtensionComponent : STURITemplateVariableComponent<STURITemplateComponent>
@end

@interface STURITemplateQueryComponent : STURITemplateVariableComponent<STURITemplateComponent>
@end

@interface STURITemplateQueryContinuationComponent : STURITemplateVariableComponent<STURITemplateComponent>
@end

@interface STURITemplatePathParameterComponent : STURITemplateVariableComponent<STURITemplateComponent>
@end


@interface STURITemplateComponentVariable : NSObject
- (id)initWithName:(NSString *)name;
@property (nonatomic,copy,readonly) NSString *name;
- (NSString *)stringWithValue:(id)value preserveCharacters:(BOOL)preserveCharacters;
@end

@interface STURITemplateComponentTruncatedVariable : STURITemplateComponentVariable
- (id)initWithName:(NSString *)name length:(NSUInteger)length;
@end

@interface STURITemplateComponentExplodedVariable : STURITemplateComponentVariable
@end


static NSArray *STURITemplateComponentsFromString(NSString *string);
//static id<STURITemplateComponent> STURITemplateComponentWithString(NSString *string);


static NSCharacterSet *STURITemplateComponentOperatorCharacterSet = nil;
static NSCharacterSet *STURITemplateComponentReservedOperatorCharacterSet = nil;
static NSCharacterSet *STURITemplateVariableNameCharacterSet = nil;

__attribute__((constructor))
static void STURITemplateInit(void) {
    STURITemplateComponentOperatorCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"+#./;?&"];
    STURITemplateComponentReservedOperatorCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"=,!@|"];
    {
        NSMutableCharacterSet * const variableNameCharacterSet = [[NSMutableCharacterSet alloc] init];
        [variableNameCharacterSet addCharactersInString:@"abcdefghijklmnopqrstuvwxyz"];
        [variableNameCharacterSet addCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
        [variableNameCharacterSet addCharactersInString:@"0123456789"];
        [variableNameCharacterSet addCharactersInString:@"_%."];
        STURITemplateVariableNameCharacterSet = variableNameCharacterSet.copy;
    }
}



static NSString *STURITemplateStringByAddingPercentEscapes(NSString *string, BOOL preserveCharacters) {
    CFStringRef const legalURLCharactersToBeEscaped = preserveCharacters ? NULL : CFSTR("!#$&'()*+,/:;=?@[]%");
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)string, NULL, legalURLCharactersToBeEscaped, kCFStringEncodingUTF8);
}


@implementation STURITemplate {
@private
    NSArray *_components;
}

- (id)init {
    return [self initWithTemplate:nil];
}
- (id)initWithTemplate:(NSString *)template {
    NSArray * const components = STURITemplateComponentsFromString(template);
    if (!components) {
        return nil;
    }

    if ((self = [super init])) {
        _components = components;
    }
    return self;
}

- (NSArray *)variableNames {
    NSMutableArray * const variableNames = [[NSMutableArray alloc] init];
    for (id<STURITemplateComponent> component in _components) {
        [variableNames addObjectsFromArray:component.variableNames];
    }
    return variableNames.copy;
}

- (NSURL *)url {
    return [NSURL URLWithString:@""];
}

- (NSURL *)urlByExpandingWithVariables:(NSDictionary *)variables {
    NSMutableString * const urlString = [[NSMutableString alloc] init];
    for (id<STURITemplateComponent> component in _components) {
        [urlString appendString:[component stringWithVariables:variables]];
    }
    return [NSURL URLWithString:urlString];
}

@end


static STURITemplateComponentVariable *STURITemplateVariableWithSpecifier(NSString *specifier) {
    NSString *name = nil;
    NSScanner * const scanner = [[NSScanner alloc] initWithString:specifier];
    [scanner scanCharactersFromSet:STURITemplateVariableNameCharacterSet intoString:&name];

    BOOL isPrefix = NO;
    unsigned long long prefixLength = 0;
    if ([scanner scanString:@":" intoString:NULL]) {
        if (![scanner scanUnsignedLongLong:&prefixLength]) {
            return nil;
        }
        isPrefix = YES;
    }
    BOOL const isExploded = [scanner scanString:@"*" intoString:NULL];
    if (!scanner.atEnd) {
        return nil;
    }
    if (isPrefix && isExploded) {
        return nil;
    }
    if (isPrefix) {
        return [[STURITemplateComponentTruncatedVariable alloc] initWithName:name length:prefixLength];
    }
    if (isExploded) {
        return [[STURITemplateComponentExplodedVariable alloc] initWithName:name];
    }
    return [[STURITemplateComponentVariable alloc] initWithName:name];
}

static NSArray *STURITemplateVariablesFromSpecification(NSString *variableSpecification) {
    NSArray * const variableSpecifiers = [variableSpecification componentsSeparatedByString:@","];
    NSMutableArray * const variables = [[NSMutableArray alloc] initWithCapacity:variableSpecifiers.count];
    for (NSString *variableSpecifier in variableSpecifiers) {
        STURITemplateComponentVariable * const variable = STURITemplateVariableWithSpecifier(variableSpecifier);
        if (!variable) {
            return nil;
        }
        if (variable) {
            [variables addObject:variable];
        }
    }
    return variables.copy;
}

//static id<STURITemplateComponent> STURITemplateComponentWithString(NSString *string) {
//    NSScanner * const scanner = [[NSScanner alloc] initWithString:string];
//
//    if (![scanner scanString:@"{" intoString:NULL]) {
//        return [[STURITemplateLiteralComponent alloc] initWithString:string];
//    }
//
//    NSString *operator = nil;
//    if ([scanner scanCharactersFromSet:STURITemplateComponentReservedOperatorCharacterSet intoString:NULL]) {
//        return nil;
//    }
//    [scanner scanCharactersFromSet:STURITemplateComponentOperatorCharacterSet intoString:&operator];
//
//    NSString *variableSpecification = nil;
//    [scanner scanUpToString:@"}" intoString:&variableSpecification];
//    [scanner scanString:@"}" intoString:NULL];
//    if (!scanner.atEnd) {
//        return nil;
//    }
//
//    NSArray * const variables = STURITemplateVariablesFromSpecification(variableSpecification);
//    if (!variables) {
//        return nil;
//    }
//
//    if (operator.length > 0) {
//        switch ([operator characterAtIndex:0]) {
//            case '+':
//                return [[STURITemplateReservedCharacterComponent alloc] initWithVariables:variables];
//            case '#':
//                return [[STURITemplateFragmentComponent alloc] initWithVariables:variables];
//            case '.':
//                return [[STURITemplatePathExtensionComponent alloc] initWithVariables:variables];
//            case '/':
//                return [[STURITemplatePathSegmentComponent alloc] initWithVariables:variables];
//            case ';':
//                return [[STURITemplatePathParameterComponent alloc] initWithVariables:variables];
//            case '?':
//                return [[STURITemplateQueryComponent alloc] initWithVariables:variables];
//            case '&':
//                return  [[STURITemplateQueryContinuationComponent alloc] initWithVariables:variables];
//        }
//        return nil;
//    }
//
//    return [[STURITemplateSimpleComponent alloc] initWithVariables:variables];
//}

//static NSArray *STURITemplateComponentsFromString(NSString *string) {
//    if (string.length == 0) {
//        return @[];
//    }
//
//    NSScanner * const scanner = [[NSScanner alloc] initWithString:string];
//
//    NSMutableArray * const components = [[NSMutableArray alloc] init];
//    while (!scanner.atEnd) {
//        NSString *s = nil;
//        if ([scanner scanUpToString:@"{" intoString:&s]) {
//            [components addObject:[[STURITemplateLiteralComponent alloc] initWithString:s]];
//        }
//        if (scanner.atEnd) {
//            break;
//        }
//
//        s = nil;
//        if (![scanner scanUpToString:@"}" intoString:&s]) {
//            return nil;
//        }
//        if (![scanner scanString:@"}" intoString:NULL]) {
//            return nil;
//        }
//        if (s.length) {
//            s = [s stringByAppendingString:@"}"];
//            id<STURITemplateComponent> const component = STURITemplateComponentWithString(s);
//            if (!component) {
//                return nil;
//            }
//            if (component) {
//                [components addObject:component];
//            }
//        }
//    };
//    
//    return components.copy;
//}




@interface STURITemplateScanner : NSObject
- (instancetype)initWithString:(NSString *)string __attribute__((objc_designated_initializer));
- (BOOL)scanString:(NSString *)string intoString:(NSString * __autoreleasing *)result;
- (BOOL)scanCharactersFromSet:(NSCharacterSet *)set intoString:(NSString **)result;
- (BOOL)scanUpToString:(NSString *)string intoString:(NSString * __autoreleasing *)result;
- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet *)set intoString:(NSString * __autoreleasing *)result;
@property (nonatomic,assign,getter=isAtEnd,readonly) BOOL atEnd;
- (BOOL)sturit_scanTemplateComponent:(id<STURITemplateComponent> __autoreleasing *)component;
@end
@implementation STURITemplateScanner {
@private
    NSScanner *_scanner;
}
- (instancetype)initWithString:(NSString *)string {
    NSScanner * const scanner = [[NSScanner alloc] initWithString:string];
    if (!scanner) {
        return nil;
    }
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
- (BOOL)sturit_scanPercentEncoded:(NSString * __autoreleasing *)result {
    NSUInteger const scanLocation = _scanner.scanLocation;

    NSMutableString * const string = @"%".mutableCopy;

    NSCharacterSet * const hexCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"];

    if (![_scanner scanString:@"%" intoString:NULL]) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }

    NSRange candidateRange = (NSRange){
        .location = _scanner.scanLocation,
    };
    candidateRange.length = MIN(2U, _scanner.string.length - candidateRange.location);
    if (candidateRange.length != 2) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }

    NSString * const candidateString = [_scanner.string substringWithRange:candidateRange];
    unichar candidateCharacters[2] = { 0 };
    [candidateString getCharacters:candidateCharacters range:(NSRange){ .length = 2 }];

    if (![hexCharacterSet characterIsMember:candidateCharacters[0]]) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }
    if (![hexCharacterSet characterIsMember:candidateCharacters[1]]) {
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

    NSMutableCharacterSet * const a = [[[NSCharacterSet illegalCharacterSet] invertedSet] mutableCopy];
    [a formIntersectionWithCharacterSet:[[NSCharacterSet controlCharacterSet] invertedSet]];
    [a formIntersectionWithCharacterSet:[[NSCharacterSet characterSetWithCharactersInString:@" \"'%<>\\^`{|}"] invertedSet]];

    NSMutableString * const string = [NSMutableString string];
    while (!_scanner.atEnd) {
        BOOL didSomething = NO;
        NSString *scratch = nil;

        if ([_scanner scanCharactersFromSet:a intoString:&scratch]) {
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
- (BOOL)sturit_scanVariableComponent:(id<STURITemplateComponent> __autoreleasing *)result {
    NSUInteger const scanLocation = _scanner.scanLocation;
    if (![_scanner scanString:@"{" intoString:NULL]) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }

    NSString *operator = nil;
    if ([_scanner scanCharactersFromSet:STURITemplateComponentReservedOperatorCharacterSet intoString:NULL]) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }
    [_scanner scanCharactersFromSet:STURITemplateComponentOperatorCharacterSet intoString:&operator];

    NSString *variableSpecification = nil;
    if (![_scanner scanUpToString:@"}" intoString:&variableSpecification]) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }
    if (![_scanner scanString:@"}" intoString:NULL]) {
        [_scanner setScanLocation:scanLocation];
        return NO;
    }

    NSArray * const variables = STURITemplateVariablesFromSpecification(variableSpecification);
    if (!variables) {
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



static NSArray *STURITemplateComponentsFromString(NSString *string) {
    if (string.length == 0) {
        return @[];
    }

    STURITemplateScanner * const scanner = [[STURITemplateScanner alloc] initWithString:string];
    if (!scanner) {
        return nil;
    }

    NSMutableArray * const components = [[NSMutableArray alloc] init];
    while (!scanner.atEnd) {
        id<STURITemplateComponent> component = nil;
        if (![scanner sturit_scanTemplateComponent:&component]) {
            return nil;
        }
        [components addObject:component];
    };

    return components.copy;
}


@implementation STURITemplateLiteralComponent {
@private
    NSString *_string;
}
- (id)init {
    return [self initWithString:nil];
}
- (id)initWithString:(NSString *)string {
    if ((self = [super init])) {
        _string = string.copy;
    }
    return self;
}
- (NSArray *)variableNames {
    return @[];
}
- (NSString *)stringWithVariables:(NSDictionary *)variables {
    return STURITemplateStringByAddingPercentEscapes(_string, YES);
}
@end

@implementation STURITemplateVariableComponent {
@protected
    NSArray *_variables;
    NSArray *_variableNames;
}
- (id)init {
    return [self initWithVariables:nil];
}
- (id)initWithVariables:(NSArray *)variables {
    if ((self = [super init])) {
        _variables = variables;
        _variableNames = [[_variables valueForKey:@"name"] sortedArrayUsingSelector:@selector(compare:)];
    }
    return self;
}
- (NSArray *)variableNames {
    return _variableNames;
}
- (NSString *)stringWithVariables:(NSDictionary *)variables prefix:(NSString *)prefix separator:(NSString *)separator asPair:(BOOL)asPair preserveCharacters:(BOOL)preserveCharacters {
    NSMutableArray * const values = [[NSMutableArray alloc] initWithCapacity:_variables.count];
    for (STURITemplateComponentVariable *variable in _variables) {
        id const value = variables[variable.name];
        if (value) {
            NSString * const string = [variable stringWithValue:value preserveCharacters:preserveCharacters];
            if (!string) {
                continue;
            }
            NSMutableString *value = [NSMutableString string];
            if (asPair) {
                [value appendFormat:@"%@=", variable.name];
            }
            if (string.length) {
                [value appendString:string];
            }
            [values addObject:value];
        }
    }
    NSString *string = [values componentsJoinedByString:separator];
    if (string.length) {
        string = [(prefix ?: @"") stringByAppendingString:string];
    }
    return string;
}
@end

@implementation STURITemplateSimpleComponent
@dynamic variableNames;
- (NSString *)stringWithVariables:(NSDictionary *)variables {
    return [super stringWithVariables:variables prefix:@"" separator:@"," asPair:NO preserveCharacters:NO];
}
@end

@implementation STURITemplateReservedCharacterComponent
@dynamic variableNames;
- (NSString *)stringWithVariables:(NSDictionary *)variables {
    return [super stringWithVariables:variables prefix:@"" separator:@"," asPair:NO preserveCharacters:YES];
}
@end

@implementation STURITemplateFragmentComponent
@dynamic variableNames;
- (NSString *)stringWithVariables:(NSDictionary *)variables {
    return [super stringWithVariables:variables prefix:@"#" separator:@"," asPair:NO preserveCharacters:YES];
}
@end

@implementation STURITemplatePathSegmentComponent
@dynamic variableNames;
- (NSString *)stringWithVariables:(NSDictionary *)variables {
    return [super stringWithVariables:variables prefix:@"/" separator:@"/" asPair:NO preserveCharacters:NO];
}
@end

@implementation STURITemplatePathExtensionComponent
@dynamic variableNames;
- (NSString *)stringWithVariables:(NSDictionary *)variables {
    return [super stringWithVariables:variables prefix:@"." separator:@"." asPair:NO preserveCharacters:NO];
}
@end

@implementation STURITemplateQueryComponent
@dynamic variableNames;
- (NSString *)stringWithVariables:(NSDictionary *)variables {
    return [super stringWithVariables:variables prefix:@"?" separator:@"&" asPair:YES preserveCharacters:NO];
}
@end

@implementation STURITemplateQueryContinuationComponent
@dynamic variableNames;
- (NSString *)stringWithVariables:(NSDictionary *)variables {
    return [super stringWithVariables:variables prefix:@"&" separator:@"&" asPair:YES preserveCharacters:NO];
}
@end

@implementation STURITemplatePathParameterComponent
@dynamic variableNames;
- (NSString *)stringWithVariables:(NSDictionary *)variables {
    NSString * const prefix = @";";
    NSString * const separator = @";";
    NSMutableArray * const values = [[NSMutableArray alloc] initWithCapacity:_variables.count];
    for (STURITemplateComponentVariable *variable in _variables) {
        id const value = variables[variable.name];
        if (value) {
            NSString * const string = [variable stringWithValue:value preserveCharacters:NO];
            if (!string) {
                continue;
            }
            NSMutableString *value = [NSMutableString string];
            [value appendString:variable.name];
            if (string.length) {
                [value appendFormat:@"=%@", string];
            }
            [values addObject:value];
        }
    }
    NSString *string = [values componentsJoinedByString:separator];
    if (string.length) {
        string = [(prefix ?: @"") stringByAppendingString:string];
    }
    return string;
}
@end


@implementation STURITemplateComponentVariable {
@private
}
- (id)init {
    return [self initWithName:nil];
}
- (id)initWithName:(NSString *)name {
    if ((self = [super init])) {
        _name = name.copy;
    }
    return self;
}
- (NSString *)stringWithValue:(id)value preserveCharacters:(BOOL)preserveCharacters {
    if (!value) {
        return nil;
    }
    if ([value isKindOfClass:[NSString class]]) {
        return STURITemplateStringByAddingPercentEscapes(value, preserveCharacters);
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)value).stringValue;
    }
    if ([value isKindOfClass:[NSArray class]]) {
        return [[((NSArray *)value) sturi_map:^(id o) {
            return STURITemplateStringByAddingPercentEscapes([NSString stringWithFormat:@"%@", o], preserveCharacters);
        }] componentsJoinedByString:@","];
    }
    return nil;
}
@end

@implementation STURITemplateComponentTruncatedVariable {
@private
    NSUInteger _length;
}
- (id)initWithName:(NSString *)name length:(NSUInteger)length {
    if ((self = [super initWithName:name])) {
        _length = length;
    }
    return self;
}
- (NSString *)stringWithValue:(id)value preserveCharacters:(BOOL)preserveCharacters {
    if (!value) {
        return nil;
    }
    NSString * const s = [NSString stringWithFormat:@"%@", value];
    return STURITemplateStringByAddingPercentEscapes([s substringToIndex:MIN(_length, s.length)], preserveCharacters);
}
@end

@implementation STURITemplateComponentExplodedVariable
- (NSString *)stringWithValue:(id)value preserveCharacters:(BOOL)preserveCharacters {
    NSAssert(0, @"unimplemented");
    return nil;
}
@end
