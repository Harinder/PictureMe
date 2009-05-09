//
//  RedactedCameraController.m
//  PictureMe
//
//  Created by Jeremy Collins on 5/8/09.
//  Copyright 2009 Beetlebug Software. All rights reserved.
//

#import "RedactedCameraController.h"


@implementation RedactedCameraController

- (void)setup {
    // /0/0/0/0/2/0/0/0/1
    UIButton *retakeButton = [[[[[[[[[[[[[[[[self.view subviews] objectAtIndex:0]
                                                       subviews] objectAtIndex:0]
                                                       subviews] objectAtIndex:0]
                                                       subviews] objectAtIndex:0]
                                                       subviews] objectAtIndex:2]
                                                       subviews] objectAtIndex:0]
                                                       subviews] objectAtIndex:0]
                                                       subviews] objectAtIndex:0];

    [retakeButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    // /0/0/0/0/2/0/1/1
    UIButton *cancelButton = [[[[[[[[[[[[[[[[self.view subviews] objectAtIndex:0]
                                                       subviews] objectAtIndex:0]
                                                       subviews] objectAtIndex:0]
                                                       subviews] objectAtIndex:0]
                                                       subviews] objectAtIndex:2]
                                                       subviews] objectAtIndex:0]
                                                       subviews] objectAtIndex:1]
                                                       subviews] objectAtIndex:1];

    [cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *captureButton = [[[[[[[[[[[[[[[[self.view subviews] objectAtIndex:0]
                                                        subviews] objectAtIndex:0]
                                                        subviews] objectAtIndex:0]
                                                        subviews] objectAtIndex:0]
                                                        subviews] objectAtIndex:2]
                                                        subviews] objectAtIndex:0]
                                                        subviews] objectAtIndex:1]
                                                        subviews] objectAtIndex:0];

    [captureButton addTarget:self action:@selector(captureButtonAction:) forControlEvents:UIControlEventTouchUpInside];        

    
}

- (void)triggerShutter {
    
    // Initial is        /0/0/0/0/2/0/1/0
    // After "Retake" is /0/0/0/0/2/0/0/0
    UIView *view = [[[[[[[[[[[[self.view subviews] objectAtIndex:0]
                                         subviews] objectAtIndex:0]
                                         subviews] objectAtIndex:0]
                                         subviews] objectAtIndex:0]
                                         subviews] objectAtIndex:2]
                                         subviews] objectAtIndex:0];

    UIButton *button;
    if([view.subviews count] == 1) {
        button = [[[[[[[[[[[[[[[[self.view subviews] objectAtIndex:0]
                                           subviews] objectAtIndex:0]
                                           subviews] objectAtIndex:0]
                                           subviews] objectAtIndex:0]
                                           subviews] objectAtIndex:2]
                                           subviews] objectAtIndex:0]
                                           subviews] objectAtIndex:0]
                                           subviews] objectAtIndex:0];        
    } else {
        button = [[[[[[[[[[[[[[[[self.view subviews] objectAtIndex:0]
                                           subviews] objectAtIndex:0]
                                           subviews] objectAtIndex:0]
                                           subviews] objectAtIndex:0]
                                           subviews] objectAtIndex:2]
                                           subviews] objectAtIndex:0]
                                           subviews] objectAtIndex:1]
                                           subviews] objectAtIndex:0];
    }
    
    [button sendActionsForControlEvents:UIControlEventTouchUpInside];  
}

-(void)previewCheck {
    
    UIView *preview;
    // Preview view path is /0/0/0/0/2.
    preview = [[[[[[[[[[self.view subviews] objectAtIndex:0]
                                  subviews] objectAtIndex:0]
                                  subviews] objectAtIndex:0]
                                  subviews] objectAtIndex:0]
                                  subviews] objectAtIndex:2];
    
    if([preview.subviews count] == 0 && !isPreview) {
        isPreview = YES;
    }

}


@end
