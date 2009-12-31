//
//  TouchCameraAppDelegate.m
//  TouchCamera
//
//  Created by Jeremy Collins on 3/11/09.
//  Copyright Jeremy Collins 2009. All rights reserved.
//

#import "PictureMeAppDelegate.h"


@implementation PictureMeAppDelegate


@synthesize window;
@synthesize main;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    [window addSubview:[main view]];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
