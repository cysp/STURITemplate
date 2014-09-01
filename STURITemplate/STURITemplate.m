//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014 Scott Talbot.

#import "STURITemplate.h"


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
- (NSString *)stringWithValue:(id)value;
@end

@interface STURITemplateComponentTruncatedVariable : STURITemplateComponentVariable
- (id)initWithName:(NSString *)name length:(NSUInteger)length;
@end

@interface STURITemplateComponentExplodableVariable : STURITemplateComponentVariable
@end


static NSArray *STURITemplateComponentsFromString(NSString *string);
static id<STURITemplateComponent> STURITemplateComponentWithString(NSString *string);


static NSCharacterSet *STURITemplateComponentOperatorCharacterSet = nil;
static NSCharacterSet *STURITemplateComponentReservedOperatorCharacterSet = nil;

__attribute__((constructor))
static void STURITemplateInit(void) {
    STURITemplateComponentOperatorCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"+#./;?&"];
    STURITemplateComponentReservedOperatorCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"=,!@|"];
}


//    ALPHA          =  %x41-5A / %x61-7A   ; A-Z / a-z
//    DIGIT          =  %x30-39             ; 0-9
//    HEXDIG         =  DIGIT / "A" / "B" / "C" / "D" / "E" / "F"
//    ; case-insensitive
//
//    pct-encoded    =  "%" HEXDIG HEXDIG
//    unreserved     =  ALPHA / DIGIT / "-" / "." / "_" / "~"
//    reserved       =  gen-delims / sub-delims
//    gen-delims     =  ":" / "/" / "?" / "#" / "[" / "]" / "@"
//    sub-delims     =  "!" / "$" / "&" / "'" / "(" / ")"
//                     /  "*" / "+" / "," / ";" / "="
//
//    ucschar        =  %xA0-D7FF / %xF900-FDCF / %xFDF0-FFEF
//    /  %x10000-1FFFD / %x20000-2FFFD / %x30000-3FFFD
//    /  %x40000-4FFFD / %x50000-5FFFD / %x60000-6FFFD
//    /  %x70000-7FFFD / %x80000-8FFFD / %x90000-9FFFD
//    /  %xA0000-AFFFD / %xB0000-BFFFD / %xC0000-CFFFD
//    /  %xD0000-DFFFD / %xE1000-EFFFD
//
//    iprivate       =  %xE000-F8FF / %xF0000-FFFFD / %x100000-10FFFD


static NSString *STURITemplateStringByAddingPercentEscapes(NSString *string, NSString *charactersToLeaveUnescaped, NSString *legalURLCharactersToBeEscaped) {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)string, (__bridge CFStringRef)charactersToLeaveUnescaped, (__bridge CFStringRef)legalURLCharactersToBeEscaped, kCFStringEncodingUTF8);
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


static NSArray *STURITemplateComponentsFromString(NSString *string) {
    if (string.length == 0) {
        return @[];
    }

    NSScanner * const scanner = [[NSScanner alloc] initWithString:string];

    NSMutableArray * const components = [[NSMutableArray alloc] init];
    while (!scanner.atEnd) {
        NSString *s = nil;
        if ([scanner scanUpToString:@"{" intoString:&s]) {
            [components addObject:[[STURITemplateLiteralComponent alloc] initWithString:s]];
        }
//        if (![scanner scanString:@"{" intoString:NULL]) {
//            return nil;
//        }
        if (scanner.atEnd) {
            break;
        }

        s = nil;
        if (![scanner scanUpToString:@"}" intoString:&s]) {
            return nil;
        }
        if (![scanner scanString:@"}" intoString:NULL]) {
            return nil;
        }
        if (s.length) {
            s = [s stringByAppendingString:@"}"];
            id<STURITemplateComponent> const component = STURITemplateComponentWithString(s);
            if (component) {
                [components addObject:component];
            }
        }
    };

    return components.copy;
}

static STURITemplateComponentVariable *STURITemplateVariableWithSpecifier(NSString *specifier) {
    NSString *name = nil;
    NSScanner * const scanner = [[NSScanner alloc] initWithString:specifier];
    [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@":*"] intoString:&name];
    if (scanner.atEnd) {
        return [[STURITemplateComponentVariable alloc] initWithName:name];
    }
    return nil;
}

static NSArray *STURITemplateVariablesFromSpecification(NSString *variableSpecification) {
    NSArray * const variableSpecifiers = [variableSpecification componentsSeparatedByString:@","];
    NSMutableArray * const variables = [[NSMutableArray alloc] initWithCapacity:variableSpecifiers.count];
    for (NSString *variableSpecifier in variableSpecifiers) {
        STURITemplateComponentVariable * const variable = STURITemplateVariableWithSpecifier(variableSpecifier);
        if (variable) {
            [variables addObject:variable];
        }
    }
    return variables.copy;
}

static id<STURITemplateComponent> STURITemplateComponentWithString(NSString *string) {
    NSScanner * const scanner = [[NSScanner alloc] initWithString:string];

    if (![scanner scanString:@"{" intoString:NULL]) {
        return [[STURITemplateLiteralComponent alloc] initWithString:string];
    }

    NSString *operator = nil;
    if ([scanner scanCharactersFromSet:STURITemplateComponentReservedOperatorCharacterSet intoString:NULL]) {
        return nil;
    }
    [scanner scanCharactersFromSet:STURITemplateComponentOperatorCharacterSet intoString:&operator];

    NSString *variableSpecification = nil;
    [scanner scanUpToString:@"}" intoString:&variableSpecification];
    [scanner scanString:@"}" intoString:NULL];
    if (!scanner.atEnd) {
        return nil;
    }

    NSArray * const variables = STURITemplateVariablesFromSpecification(variableSpecification);

//    +#./;?&
    if (operator.length > 0) {
        switch ([operator characterAtIndex:0]) {
            case '+':
                return [[STURITemplateReservedCharacterComponent alloc] initWithVariables:variables];
            case '#':
                return [[STURITemplateFragmentComponent alloc] initWithVariables:variables];
            case '.':
                return [[STURITemplatePathExtensionComponent alloc] initWithVariables:variables];
            case '/':
                return [[STURITemplatePathSegmentComponent alloc] initWithVariables:variables];
            case ';':
                return [[STURITemplatePathParameterComponent alloc] initWithVariables:variables];
            case '?':
                return [[STURITemplateQueryComponent alloc] initWithVariables:variables];
            case '&':
                return  [[STURITemplateQueryContinuationComponent alloc] initWithVariables:variables];
        }
        return nil;
    }

    return [[STURITemplateSimpleComponent alloc] initWithVariables:variables];
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
    return STURITemplateStringByAddingPercentEscapes(_string, nil, nil);
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
    NSString * const charactersToEscape = preserveCharacters ? nil : @"!#$&'()*+,/:;=?@[]%";

    NSMutableArray * const values = [[NSMutableArray alloc] initWithCapacity:_variables.count];
    for (STURITemplateComponentVariable *variable in _variables) {
        id const value = variables[variable.name];
        if (value) {
            NSString * const string = [variable stringWithValue:value];
            if (!string) {
                continue;
            }
            NSMutableString *value = [NSMutableString string];
            if (asPair) {
                [value appendFormat:@"%@=", STURITemplateStringByAddingPercentEscapes(variable.name, nil, charactersToEscape)];
            }
            if (string.length) {
                [value appendString:STURITemplateStringByAddingPercentEscapes(string, nil, charactersToEscape)];
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
    return [super stringWithVariables:variables prefix:@";" separator:@";" asPair:YES preserveCharacters:NO];
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
- (NSString *)stringWithValue:(id)value {
    if (!value) {
        return nil;
    }
    return [NSString stringWithFormat:@"%@", value];
//    if ([value isKindOfClass:[NSString class]]) {
//        return value;
//    }
//    if ([value isKindOfClass:[NSNumber class]]) {
//        return ((NSNumber *)value).stringValue;
//    }
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
- (NSString *)stringWithValue:(id)value {
    if (!value) {
        return nil;
    }
    NSString * const s = [NSString stringWithFormat:@"%@", value];
    return [s substringToIndex:MIN(_length, s.length)];
}
@end

@implementation STURITemplateComponentExplodableVariable
- (NSString *)stringWithValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    if ([value isKindOfClass:[NSArray class]]) {
        return [(NSArray *)value componentsJoinedByString:@","];
    }
    return nil;
}
@end
