#import "STURITemplateParser.h"
#import "STURITemplate+Internal.h"

#import <Foundation/Foundation.h>

#import <inttypes.h>
#import <stdbool.h>
#import <stdint.h>
#import <stdlib.h>


%%{
	machine uritemplate;

    action literal_start {
        memset(&s.literal, 0, sizeof(s.literal));
        s.literal.start = p;
    }
    action literal_finish {
        char const * const start = s.literal.start;

        size_t const len = (size_t)(p - start);
        NSString * const literal = [[NSString alloc] initWithBytes:start length:len encoding:NSUTF8StringEncoding];
        [components addObject:[[STURITemplateLiteralComponent alloc] initWithString:literal]];
    }

    action expression_start {
        memset(&s.expression, 0, sizeof(s.expression));
        variables = [[NSMutableArray alloc] initWithCapacity:4];
        s.in_expression = 1;
    }
    action expression_operator {
        char const op = *(p - 1);
        s.expression.operator = op;
    }
    action varspec_start {
        memset(&s.variable, 0, sizeof(s.variable));
    }
    action varname_start {
        s.variable.name_start = p;
    }
    action varname_store {
        s.variable.name_len = (size_t)(p - s.variable.name_start);
    }
    action var_modifier_prefix_start {
        s.variable.modifier.prefix_start = p;
    }
    action var_modifier_store_prefix {
        char const * const start = s.variable.modifier.prefix_start;
        long prefix = strtol(start, NULL, 10);
        s.variable.modifier.prefix = (int)prefix;
    }
    action var_modifier_store_explode {
        s.variable.modifier.explode = 1;
    }
    action varspec_push {
        NSString * const name = [[NSString alloc] initWithBytes:s.variable.name_start length:s.variable.name_len encoding:NSUTF8StringEncoding];
        bool const explode = s.variable.modifier.explode;
        long const prefix = s.variable.modifier.prefix;
        STURITemplateComponentVariable *variable = nil;
        if (explode) {
            variable = [[STURITemplateComponentExplodedVariable alloc] initWithName:name];
        }
        if (!variable && prefix) {
            variable = [[STURITemplateComponentTruncatedVariable alloc] initWithName:name length:(NSUInteger)prefix];
        }
        if (!variable) {
            variable = [[STURITemplateComponentVariable alloc] initWithName:name];
        }
        if (variable) {
            [variables addObject:variable];
        }
    }
    action expression_finish {
        id<STURITemplateComponent> component = nil;
        switch (s.expression.operator) {
            case '\0':
                component = [[STURITemplateSimpleComponent alloc] initWithVariables:variables];
                break;
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
            return nil;
        }
        if (component) {
            [components addObject:component];
        }
        variables = nil;
        s.in_expression = 0;
    }

    ALPHA = [A-Za-z];
    DIGIT = [0-9];
    HEXDIG = [0-9A-Fa-f];

    pctencoded = '%' HEXDIG HEXDIG;
    unreserved = ALPHA | DIGIT | "-" | "." | "_" | "~";
    gendelims = ":" | "|" | "?" | "#" | "[" | "]" | "@";
    subdelims = "!" | "$" | "&" | "'" | "(" | ")"
                    |  "*" | "+" | "," | ";" | "=";
    reserved = gendelims | subdelims;

    literals = 0x21 | 0x23..0x24 | 0x26 | 0x28..0x3B | 0x3D | 0x3F..0x5B
        |  0x5D | 0x5F | 0x61..0x7A | 0x7E
        |  pctencoded;

    maxlength = [1-9] [0-9]{,3};
    prefix = ':' $var_modifier_prefix_start maxlength %var_modifier_store_prefix;
    explode = '*' %var_modifier_store_explode;
    modifierlevel4 =  prefix | explode;

    oplevel2 = '+' | '#';
    oplevel3 = '.' | '/' | '|' | ';' | '?' | '&';
    opreserve = '=' | ',' | '!' | '@' | '|';
    operator = oplevel2 | oplevel3 | opreserve;

    varchar = ALPHA | DIGIT | '_' | pctencoded;
    varname = varchar ( '.'? varchar )*;
    varspec = (varname >varname_start %varname_store) modifierlevel4?;
    variablelistitem = varspec  >varspec_start %varspec_push;
    variablelist = variablelistitem ( ',' variablelistitem )*;

    expression = '{' ( operator %expression_operator )? variablelist '}';

    main := ( ((literals+) >literal_start %literal_finish ) | (expression >expression_start %expression_finish) )*;
}%%


%% write data;


enum sturitemplate_parser_state {
    sturitemplate_parser_state_literal = 0,
    sturitemplate_parser_state_in_expression,
};
struct sturitemplate_parser_scratch {
    bool in_expression;
    struct {
        char const *start;
    } literal;
    struct {
        char operator;
    } expression;
    struct {
        char const *name_start;
        size_t name_len;
        struct {
            int explode : 1;
            char const *prefix_start;
            int prefix;
        } modifier;
    } variable;
};

NSArray *sturitemplate_parse(NSString *string) {
    NSData * const data = [string dataUsingEncoding:NSUTF8StringEncoding];
    char const *p = data.bytes;
    size_t plen = data.length;

    NSMutableArray * const components = [[NSMutableArray alloc] initWithCapacity:16];
    NSMutableArray *variables = nil;

	struct sturitemplate_parser_scratch s = {};

	char const *pe = p + plen;
	char const *eof = p + plen;
    int cs = 0;

	%% write init;
	%% write exec;

    (void)uritemplate_first_final;
    (void)uritemplate_error;
    (void)uritemplate_en_main;

    if (p != pe) {
        return nil;
    }
    if (s.in_expression) {
        return nil;
    }

    return components.copy;
}
