//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright © 2014-2016 Scott Talbot.

#import <STURITemplate/STURITemplate.h>


typedef NS_ENUM(NSInteger, STURITemplateEscapingStyle) {
    STURITemplateEscapingStyleU,
    STURITemplateEscapingStyleUR,
};


@protocol STURITemplateComponent <NSObject>
@property (nonatomic,copy,nonnull,readonly) NSArray<NSString *> *variableNames;
- (NSString * __nonnull)stringWithVariables:(NSDictionary<NSString *, id> * __nullable)variables;
- (NSString * __nonnull)templateRepresentation;
@end


@interface STURITemplateLiteralComponent : NSObject<STURITemplateComponent>
- (instancetype __null_unspecified)init NS_UNAVAILABLE;
- (instancetype __nonnull)initWithString:(NSString * __nonnull)string NS_DESIGNATED_INITIALIZER;
@end

@interface STURITemplateVariableComponent : NSObject
- (instancetype __null_unspecified)init NS_UNAVAILABLE;
- (instancetype __nonnull)initWithVariables:(NSArray<NSString *> * __nonnull)variables NS_DESIGNATED_INITIALIZER;
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
- (instancetype __null_unspecified)init NS_UNAVAILABLE;
- (instancetype __nonnull)initWithName:(NSString * __nonnull)name;
@property (nonatomic,copy,nonnull,readonly) NSString *name;
- (NSString * __nullable)stringWithValue:(id __nonnull)value encodingStyle:(STURITemplateEscapingStyle)encodingStyle;
- (NSString * __nonnull)templateRepresentation;
@end

@interface STURITemplateComponentTruncatedVariable : STURITemplateComponentVariable
- (instancetype __nonnull)initWithName:(NSString * __nonnull)name length:(NSUInteger)length;
- (NSString * __nonnull)templateRepresentation;
@end

@interface STURITemplateComponentExplodedVariable : STURITemplateComponentVariable
- (NSString * __nonnull)templateRepresentation;
@end


@interface STURITemplateScanner : NSObject
- (instancetype __null_unspecified)init NS_UNAVAILABLE;
- (instancetype __nonnull)initWithString:(NSString * __nonnull)string NS_DESIGNATED_INITIALIZER;
- (BOOL)scanString:(NSString * __nonnull)string intoString:(NSString * __nullable __autoreleasing * __nullable)result;
- (BOOL)scanCharactersFromSet:(NSCharacterSet * __nonnull)set intoString:(NSString * __nullable __autoreleasing * __nullable)result;
- (BOOL)scanUpToString:(NSString * __nonnull)string intoString:(NSString * __nullable __autoreleasing * __nullable)result;
- (BOOL)scanUpToCharactersFromSet:(NSCharacterSet * __nonnull)set intoString:(NSString * __nullable __autoreleasing * __nullable)result;
@property (nonatomic,assign,getter=isAtEnd,readonly) BOOL atEnd;
- (BOOL)sturit_scanTemplateComponent:(id<STURITemplateComponent> __nullable __autoreleasing * __nullable)component;
@end
