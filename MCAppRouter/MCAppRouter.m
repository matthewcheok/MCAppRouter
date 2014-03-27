//
//  MCAppRouter.m
//  MCAppRouterDemo
//
//  Created by Matthew Cheok on 20/3/14.
//  Copyright (c) 2014 Matthew Cheok. All rights reserved.
//

#import "MCAppRouter.h"

static NSString *const kMCAppRouterStoryboardNameKey      = @"kMCAppRouterStoryboardNameKey";
static NSString *const kMCAppRouterStoryboardIdentiferKey = @"kMCAppRouterStoryboardIdentiferKey";
static NSString *const kMCAppRouterViewControllerClassKey = @"kMCAppRouterViewControllerClassKey";
static NSString *const kMCAppRouterParametersKey = @"kMCAppRouterParametersKey";

static NSString *const kMCAppRouterParameterMatchingRegex = @"\\/:(\\w+(?:\\.\\w+)*)\\/";
static NSString *const kMCAppRouterHexColorMatchingRegex = @"^#(?:[0-9a-fA-F]{3}){1,2}$";


@interface UIColor (MCAppRouter)

+ (UIColor *)colorFromWebColorString:(NSString *)colorString;

@end

@implementation UIColor (MCAppRouter)

+ (UIColor *)colorFromWebColorString:(NSString *)colorString {

	NSUInteger length = [colorString length];
	if (length > 0) {
		// remove prefixed #
		colorString = [colorString stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"#"]];
		length = [colorString length];

		// calculate substring ranges of each color
		// FFF or FFFFFF
		NSRange redRange, blueRange, greenRange;
		if (length == 3) {
			redRange = NSMakeRange(0, 1);
			greenRange = NSMakeRange(1, 1);
			blueRange = NSMakeRange(2, 1);
		} else if (length == 6) {
			redRange = NSMakeRange(0, 2);
			greenRange = NSMakeRange(2, 2);
			blueRange = NSMakeRange(4, 2);
		} else {
			return nil;
		}

		// extract colors
		unsigned int redComponent, greenComponent, blueComponent;
		BOOL valid = YES;
		NSScanner *scanner = [NSScanner scannerWithString:[colorString substringWithRange:redRange]];
		valid = [scanner scanHexInt:&redComponent];

		scanner = [NSScanner scannerWithString:[colorString substringWithRange:greenRange]];
		valid = ([scanner scanHexInt:&greenComponent] && valid);

		scanner = [NSScanner scannerWithString:[colorString substringWithRange:blueRange]];
		valid = ([scanner scanHexInt:&blueComponent] && valid);

		if (valid) {
			return [UIColor colorWithRed:redComponent/255.0 green:greenComponent/255.0 blue:blueComponent/255.0 alpha:1.0f];
		}
	}

	return nil;
}

@end

@implementation UINavigationController (MCAppRouter)

- (void)pushViewControllerMatchingRoute:(NSString *)route animated:(BOOL)animated {
    UIViewController *controller = [[MCAppRouter sharedInstance] viewControllerMatchingRoute:route];
    [self pushViewController:controller animated:animated];
}

@end

@interface MCAppRouter ()

@property (strong, nonatomic) NSMapTable *routes;
@property (strong, nonatomic) NSRegularExpression *parameterRegex;
@property (strong, nonatomic) NSRegularExpression *colorRegex;

@end

@implementation MCAppRouter

+ (instancetype)sharedInstance {
	static dispatch_once_t pred = 0;
	__strong static id _sharedObject = nil;
	dispatch_once(&pred, ^{
	    _sharedObject = [[self alloc] init];
	});
	return _sharedObject;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		_routes = [NSMapTable strongToStrongObjectsMapTable];
	}
	return self;
}

#pragma mark - Private

- (NSRegularExpression *)parameterRegex {
    if (!_parameterRegex) {
        _parameterRegex = [NSRegularExpression regularExpressionWithPattern:kMCAppRouterParameterMatchingRegex options:0 error:nil];
    }
    return _parameterRegex;
}

- (NSRegularExpression *)colorRegex {
    if (!_colorRegex) {
        _colorRegex = [NSRegularExpression regularExpressionWithPattern:kMCAppRouterHexColorMatchingRegex options:0 error:nil];
    }
    return _colorRegex;
}

- (NSString *)normalizedStringFromString:(NSString *)string {
	if (![string hasPrefix:@"/"]) {
		string = [NSString stringWithFormat:@"/%@", string];
	}
	if (![string hasSuffix:@"/"]) {
		string = [NSString stringWithFormat:@"%@/", string];
	}
	return string;
}

- (void)setupExpressionMatchingRoute:(NSString *)route withDictionary:(NSDictionary *)dictionary {
	route = [self normalizedStringFromString:route];

	NSArray *results = [self.parameterRegex matchesInString:route options:0 range:NSMakeRange(0, [route length])];

	NSUInteger location = 0;
	NSMutableString *pattern = [NSMutableString stringWithString:@"^"];
	NSMutableArray *params = [NSMutableArray array];

	for (NSTextCheckingResult *result in results) {
		NSString *keyPath = [route substringWithRange:[result rangeAtIndex:1]];
		[params addObject:keyPath];

		NSString *subString = [route substringWithRange:NSMakeRange(location, result.range.location - location)];
		[pattern appendString:[NSRegularExpression escapedPatternForString:subString]];
		[pattern appendString:@"\\/([^\\/]+)\\/"];
		location = result.range.location + result.range.length;
	}

	if (location < [route length]) {
		NSString *subString = [route substringWithRange:NSMakeRange(location, [route length] - location)];
		[pattern appendString:[NSRegularExpression escapedPatternForString:subString]];
	}
	[pattern appendString:@"$"];

	NSRegularExpression *key = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionAnchorsMatchLines error:nil];
    NSMutableDictionary *object = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    object[kMCAppRouterParametersKey] = [params copy];
    [self.routes setObject:[object copy] forKey:key];
}

#pragma mark - Methods

- (void)mapRoute:(NSString *)route toViewControllerClass:(Class)class {
	[self setupExpressionMatchingRoute:route withDictionary:@{
	     kMCAppRouterViewControllerClassKey: class
	 }];
}

- (void)mapRoute:(NSString *)route toViewControllerInStoryboardWithName:(NSString *)name withIdentifer:(NSString *)identifer {
	[self setupExpressionMatchingRoute:route withDictionary:@{
	     kMCAppRouterStoryboardNameKey: name,
	     kMCAppRouterStoryboardIdentiferKey: identifer
	 }];
}

- (id)viewControllerMatchingRoute:(NSString *)route {
	route = [self normalizedStringFromString:route];
    NSMutableArray *values = [NSMutableArray array];

    NSRegularExpression *key = nil;
	for (NSRegularExpression *expression in self.routes) {
		NSArray *results = [expression matchesInString:route options:NSMatchingAnchored range:NSMakeRange(0, [route length])];
		NSTextCheckingResult *result = [results firstObject];
        if (result) {
            for (int i = 1; i < [result numberOfRanges]; i++) {
                [values addObject:[route substringWithRange:[result rangeAtIndex:i]]];
            }
            key = expression;
        }

        if (key) {
            break;
        }
	}

    UIViewController *controller = nil;
    NSDictionary *dictionary = [self.routes objectForKey:key];
    if ([dictionary objectForKey:kMCAppRouterViewControllerClassKey]) {
        Class class = dictionary[kMCAppRouterViewControllerClassKey];
        controller = [[class alloc] init];
    }
    else if ([dictionary objectForKey:kMCAppRouterStoryboardIdentiferKey]) {
        NSString *storyboardName = dictionary[kMCAppRouterStoryboardNameKey];
        NSString *identifer = dictionary[kMCAppRouterStoryboardIdentiferKey];
        controller = [[UIStoryboard storyboardWithName:storyboardName bundle:nil] instantiateViewControllerWithIdentifier:identifer];
    }

    NSArray *params = dictionary[kMCAppRouterParametersKey];
    if ([params count] == [values count]) {
        for (int i=0; i<[params count]; i++) {
            NSString *keyPath = params[i];
            NSString *value = values[i];

            // check if hex color
            if ([self.colorRegex numberOfMatchesInString:value options:NSMatchingAnchored range:NSMakeRange(0, [value length])] > 0) {
                UIColor *color = [UIColor colorFromWebColorString:value];
                [controller setValue:color forKeyPath:keyPath];
            }
            // otherwise assume string
            else {
                [controller setValue:value forKeyPath:keyPath];
            }
        }
    }

	return controller;
}

@end
