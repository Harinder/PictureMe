//
//  PMToolbar.m
//  PictureMe
//
//  Created by Jeremy Collins on 12/29/09.
//  Copyright 2009 Beetlebug Software, LLC. All rights reserved.
//

#import "PictureMeCameraBar.h"
#import "PictureMeController.h"


@implementation PictureMeCameraBar


@synthesize delegate;


- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        UIButton *cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 98, 40)];
        [cameraButton setImage:[UIImage imageNamed:@"camera-button.png"] forState:UIControlStateNormal];
        [cameraButton setImage:[UIImage imageNamed:@"camera-button-depressed.png"] forState:UIControlStateHighlighted];
        [cameraButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *cameraButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cameraButton];
        
        self.items = [NSArray arrayWithObjects:
                      [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                      cameraButtonItem,
                      [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                      nil];
        
        [cameraButton release];
        [cameraButtonItem release];    
    }
    
    return self;
}


- (void)takePicture:(id)sender {
    if(delegate) {
    	[delegate takePicture];
    }
}


- (void)drawRect:(CGRect)rect {
    [[UIImage imageNamed:@"toolbar-gradient.png"] drawInRect:rect];
}


@end
