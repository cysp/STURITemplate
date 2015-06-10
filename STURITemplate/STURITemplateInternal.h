//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
//  Copyright (c) 2014-2015 Scott Talbot.

#import <Foundation/Foundation.h>


@protocol STURITemplateComponent <NSObject>
@property (nonatomic,copy,readonly) NSArray *variableNames;
- (NSString *)stringWithVariables:(NSDictionary *)variables;
- (NSString *)templateRepresentation;
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


typedef NS_ENUM(NSInteger, STURITemplateEscapingStyle) {
    STURITemplateEscapingStyleU,
    STURITemplateEscapingStyleUR,
};

@interface STURITemplateComponentVariable : NSObject
- (id)initWithName:(NSString *)name;
@property (nonatomic,copy,readonly) NSString *name;
- (NSString *)stringWithValue:(id)value encodingStyle:(STURITemplateEscapingStyle)encodingStyle;
- (NSString *)templateRepresentation;
@end

@interface STURITemplateComponentTruncatedVariable : STURITemplateComponentVariable
- (id)initWithName:(NSString *)name length:(NSUInteger)length;
- (NSString *)templateRepresentation;
@end

@interface STURITemplateComponentExplodedVariable : STURITemplateComponentVariable
- (NSString *)templateRepresentation;
@end
