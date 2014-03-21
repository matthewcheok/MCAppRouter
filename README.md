MCAppRouter ![License MIT](https://go-shields.herokuapp.com/license-MIT-blue.png)
===========

[![Badge w/ Version](https://cocoapod-badges.herokuapp.com/v/MCAppRouter/badge.png)](https://github.com/matthewcheok/MCAppRouter)
[![Badge w/ Platform](https://cocoapod-badges.herokuapp.com/p/MCAppRouter/badge.svg)](https://github.com/matthewcheok/MCAppRouter)

URL routing for iOS made simple.

## Installation

Add the following to your [CocoaPods](http://cocoapods.org/) Podfile

    pod 'MCAppRouter'

or clone as a git submodule,

or just copy files in the ```MCAppRouter``` folder into your project.

## Setting up MCAppRouter

Add URL mappings as follows, preferrably in your App Delegate, specifying parameters prefixed with colon. The parameters are passed to each instance by setting the properties with key paths (See [NSKeyValueCoding](https://developer.apple.com/library/ios/documentation/cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html)).

When instantiating from a UIViewController subclass:

    [[MCAppRouter sharedInstance] mapRoute:@"color/:view.backgroundColor/" toViewControllerClass:[UIViewController class]];

When instantiating from a storyboard:

    [[MCAppRouter sharedInstance] mapRoute:@"/user/:userID/display_name/:userName/" toViewControllerInStoryboardWithName:@"Main" withIdentifer:@"MCDemoViewController"];

## Using MCAppRouter

Afterward, retrieve an instance of the required view controller like this:

    UIViewController *controller = [[MCAppRouter sharedInstance] viewControllerMatchingRoute:@"/color/#2C99F8/"];

Or push it directly on a `UINavigationController`:

    [self.navigationController pushViewControllerMatchingRoute:@"user/201/display_name/Michael" animated:YES];

## Parameters

Parameter values are always assumed to be `NSString` unless stated otherwise. Currently strings containing colors in hex format are converted to `UIColor` before being passed to instances. Other suggestions are welcomed.


## License

MCAppRouter is under the MIT license.
