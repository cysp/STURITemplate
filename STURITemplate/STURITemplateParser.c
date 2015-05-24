
#line 1 "STURITemplate/STURITemplateParser.rl"
#import "STURITemplateParser.h"
#import "STURITemplateInternal.h"

#import <Foundation/Foundation.h>

#import <inttypes.h>
#import <stdbool.h>
#import <stdint.h>
#import <stdlib.h>



#line 146 "STURITemplate/STURITemplateParser.rl"




#line 21 "STURITemplate/STURITemplateParser.c"
static const char _uritemplate_actions[] = {
	0, 1, 0, 1, 1, 1, 2, 1, 
	6, 1, 11, 2, 1, 0, 2, 1, 
	2, 2, 4, 5, 2, 6, 7, 2, 
	6, 10, 2, 8, 10, 2, 9, 10, 
	2, 11, 0, 2, 11, 2, 3, 3, 
	4, 5
};

static const unsigned char _uritemplate_key_offsets[] = {
	0, 0, 6, 12, 32, 40, 46, 52, 
	65, 67, 75, 83, 85, 89, 93, 97, 
	99, 114, 129
};

static const char _uritemplate_trans_keys[] = {
	48, 57, 65, 70, 97, 102, 48, 57, 
	65, 70, 97, 102, 33, 35, 37, 38, 
	59, 61, 95, 124, 43, 44, 46, 47, 
	48, 57, 63, 64, 65, 90, 97, 122, 
	37, 95, 48, 57, 65, 90, 97, 122, 
	48, 57, 65, 70, 97, 102, 48, 57, 
	65, 70, 97, 102, 37, 42, 44, 46, 
	58, 95, 125, 48, 57, 65, 90, 97, 
	122, 44, 125, 37, 95, 48, 57, 65, 
	90, 97, 122, 37, 95, 48, 57, 65, 
	90, 97, 122, 49, 57, 44, 125, 48, 
	57, 44, 125, 48, 57, 44, 125, 48, 
	57, 44, 125, 33, 37, 61, 93, 95, 
	123, 126, 35, 38, 40, 59, 63, 91, 
	97, 122, 33, 37, 61, 93, 95, 123, 
	126, 35, 38, 40, 59, 63, 91, 97, 
	122, 33, 37, 61, 93, 95, 123, 126, 
	35, 38, 40, 59, 63, 91, 97, 122, 
	0
};

static const char _uritemplate_single_lengths[] = {
	0, 0, 0, 8, 2, 0, 0, 7, 
	2, 2, 2, 0, 2, 2, 2, 2, 
	7, 7, 7
};

static const char _uritemplate_range_lengths[] = {
	0, 3, 3, 6, 3, 3, 3, 3, 
	0, 3, 3, 1, 1, 1, 1, 0, 
	4, 4, 4
};

static const char _uritemplate_index_offsets[] = {
	0, 0, 4, 8, 23, 29, 33, 37, 
	48, 51, 57, 63, 65, 69, 73, 77, 
	80, 92, 104
};

static const char _uritemplate_indicies[] = {
	0, 0, 0, 1, 2, 2, 2, 1, 
	3, 3, 4, 3, 3, 3, 5, 3, 
	3, 3, 5, 3, 5, 5, 1, 6, 
	7, 7, 7, 7, 1, 8, 8, 8, 
	1, 9, 9, 9, 1, 10, 11, 12, 
	13, 14, 9, 15, 9, 9, 9, 1, 
	16, 17, 1, 4, 5, 5, 5, 5, 
	1, 10, 9, 9, 9, 9, 1, 18, 
	1, 19, 21, 20, 1, 19, 21, 22, 
	1, 19, 21, 23, 1, 19, 21, 1, 
	24, 25, 24, 24, 24, 26, 24, 24, 
	24, 24, 24, 1, 27, 28, 27, 27, 
	27, 29, 27, 27, 27, 27, 27, 1, 
	30, 31, 30, 30, 30, 32, 30, 30, 
	30, 30, 30, 1, 0
};

static const char _uritemplate_trans_targs[] = {
	2, 0, 17, 4, 5, 7, 5, 7, 
	6, 7, 5, 8, 9, 10, 11, 18, 
	9, 18, 12, 9, 13, 18, 14, 15, 
	17, 1, 3, 17, 1, 3, 17, 1, 
	3
};

static const char _uritemplate_trans_actions[] = {
	0, 0, 0, 0, 17, 17, 38, 38, 
	0, 0, 0, 7, 23, 0, 20, 23, 
	29, 29, 0, 26, 0, 26, 0, 0, 
	1, 1, 5, 11, 11, 14, 32, 32, 
	35
};

static const char _uritemplate_eof_actions[] = {
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 0, 0, 0, 0, 0, 0, 0, 
	0, 3, 9
};

static const int uritemplate_start = 16;
static const int uritemplate_first_final = 16;
static const int uritemplate_error = 0;

static const int uritemplate_en_main = 16;


#line 150 "STURITemplate/STURITemplateParser.rl"


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

	
#line 165 "STURITemplate/STURITemplateParser.c"
	{
	cs = uritemplate_start;
	}

#line 190 "STURITemplate/STURITemplateParser.rl"
	
#line 172 "STURITemplate/STURITemplateParser.c"
	{
	int _klen;
	unsigned int _trans;
	const char *_acts;
	unsigned int _nacts;
	const char *_keys;

	if ( p == pe )
		goto _test_eof;
	if ( cs == 0 )
		goto _out;
_resume:
	_keys = _uritemplate_trans_keys + _uritemplate_key_offsets[cs];
	_trans = _uritemplate_index_offsets[cs];

	_klen = _uritemplate_single_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + _klen - 1;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + ((_upper-_lower) >> 1);
			if ( (*p) < *_mid )
				_upper = _mid - 1;
			else if ( (*p) > *_mid )
				_lower = _mid + 1;
			else {
				_trans += (unsigned int)(_mid - _keys);
				goto _match;
			}
		}
		_keys += _klen;
		_trans += _klen;
	}

	_klen = _uritemplate_range_lengths[cs];
	if ( _klen > 0 ) {
		const char *_lower = _keys;
		const char *_mid;
		const char *_upper = _keys + (_klen<<1) - 2;
		while (1) {
			if ( _upper < _lower )
				break;

			_mid = _lower + (((_upper-_lower) >> 1) & ~1);
			if ( (*p) < _mid[0] )
				_upper = _mid - 2;
			else if ( (*p) > _mid[1] )
				_lower = _mid + 2;
			else {
				_trans += (unsigned int)((_mid - _keys)>>1);
				goto _match;
			}
		}
		_trans += _klen;
	}

_match:
	_trans = _uritemplate_indicies[_trans];
	cs = _uritemplate_trans_targs[_trans];

	if ( _uritemplate_trans_actions[_trans] == 0 )
		goto _again;

	_acts = _uritemplate_actions + _uritemplate_trans_actions[_trans];
	_nacts = (unsigned int) *_acts++;
	while ( _nacts-- > 0 )
	{
		switch ( *_acts++ )
		{
	case 0:
#line 15 "STURITemplate/STURITemplateParser.rl"
	{
        memset(&s.literal, 0, sizeof(s.literal));
        s.literal.start = p;
    }
	break;
	case 1:
#line 19 "STURITemplate/STURITemplateParser.rl"
	{
        char const * const start = s.literal.start;

        size_t const len = (size_t)(p - start);
        NSString * const literal = [[NSString alloc] initWithBytes:start length:len encoding:NSUTF8StringEncoding];
        [components addObject:[[STURITemplateLiteralComponent alloc] initWithString:literal]];
    }
	break;
	case 2:
#line 27 "STURITemplate/STURITemplateParser.rl"
	{
        memset(&s.expression, 0, sizeof(s.expression));
        variables = [[NSMutableArray alloc] initWithCapacity:4];
        s.in_expression = 1;
    }
	break;
	case 3:
#line 32 "STURITemplate/STURITemplateParser.rl"
	{
        char const op = *(p - 1);
        s.expression.operator = op;
    }
	break;
	case 4:
#line 36 "STURITemplate/STURITemplateParser.rl"
	{
        memset(&s.variable, 0, sizeof(s.variable));
    }
	break;
	case 5:
#line 39 "STURITemplate/STURITemplateParser.rl"
	{
        s.variable.name_start = p;
    }
	break;
	case 6:
#line 42 "STURITemplate/STURITemplateParser.rl"
	{
        s.variable.name_len = (size_t)(p - s.variable.name_start);
    }
	break;
	case 7:
#line 45 "STURITemplate/STURITemplateParser.rl"
	{
        s.variable.modifier.prefix_start = p;
    }
	break;
	case 8:
#line 48 "STURITemplate/STURITemplateParser.rl"
	{
        char const * const start = s.variable.modifier.prefix_start;
        long prefix = strtol(start, NULL, 10);
        s.variable.modifier.prefix = (int)prefix;
    }
	break;
	case 9:
#line 53 "STURITemplate/STURITemplateParser.rl"
	{
        s.variable.modifier.explode = 1;
    }
	break;
	case 10:
#line 56 "STURITemplate/STURITemplateParser.rl"
	{
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
	break;
	case 11:
#line 74 "STURITemplate/STURITemplateParser.rl"
	{
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
	break;
#line 377 "STURITemplate/STURITemplateParser.c"
		}
	}

_again:
	if ( cs == 0 )
		goto _out;
	if ( ++p != pe )
		goto _resume;
	_test_eof: {}
	if ( p == eof )
	{
	const char *__acts = _uritemplate_actions + _uritemplate_eof_actions[cs];
	unsigned int __nacts = (unsigned int) *__acts++;
	while ( __nacts-- > 0 ) {
		switch ( *__acts++ ) {
	case 1:
#line 19 "STURITemplate/STURITemplateParser.rl"
	{
        char const * const start = s.literal.start;

        size_t const len = (size_t)(p - start);
        NSString * const literal = [[NSString alloc] initWithBytes:start length:len encoding:NSUTF8StringEncoding];
        [components addObject:[[STURITemplateLiteralComponent alloc] initWithString:literal]];
    }
	break;
	case 11:
#line 74 "STURITemplate/STURITemplateParser.rl"
	{
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
	break;
#line 443 "STURITemplate/STURITemplateParser.c"
		}
	}
	}

	_out: {}
	}

#line 191 "STURITemplate/STURITemplateParser.rl"

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
