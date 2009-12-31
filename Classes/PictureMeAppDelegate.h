//
//  TouchCameraAppDelegate.h
//  TouchCamera
//
//  Created by Jeremy Collins on 3/11/09.
//  Copyright Jeremy Collins 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PictureMeController.h"

@interface PictureMeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PictureMeController *main;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PictureMeController *main;

@end

