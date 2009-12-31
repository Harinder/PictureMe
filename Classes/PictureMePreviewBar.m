//
//  PictureMePreviewBar.m
//  PictureMe
//
//  Created by Jeremy Collins on 12/30/09.
//  Copyright 2009 Beetlebug Software, LLC. All rights reserved.
//

#import "PictureMePreviewBar.h"
#import "PictureMeController.h"


@implementation PictureMePreviewBar


@synthesize delegate;
@synthesize statusLabel;
@synthesize retakeButton;
@synthesize useButton;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.retakeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 54, 40)];
        [retakeButton setImage:[UIImage imageNamed:@"retake-button.png"] forState:UIControlStateNormal];
        [retakeButton setImage:[UIImage imageNamed:@"retake-button-depressed.png"] forState:UIControlStateHighlighted];
        [retakeButton addTarget:self action:@selector(retakePicture:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *retakeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:retakeButton];

        self.useButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 54, 40)];
        [useButton setImage:[UIImage imageNamed:@"use-button.png"] forState:UIControlStateNormal];
        [useButton setImage:[UIImage imageNamed:@"use-button-depressed.png"] forState:UIControlStateHighlighted];
        [useButton addTarget:self action:@selector(usePicture:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *useButtonItem = [[UIBarButtonItem alloc] initWithCustomView:useButton];        
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
        statusLabel.textAlignment = UITextAlignmentCenter;
        statusLabel.font = [UIFont boldSystemFontOfSize:15.0];
        statusLabel.textColor = [UIColor colorWithRed:0.126 green:0.126 blue:0.129 alpha:1.000];
        statusLabel.shadowColor = [UIColor colorWithRed:0.773 green:0.779 blue:0.793 alpha:1.000];
        statusLabel.backgroundColor = [UIColor clearColor];
        statusLabel.shadowOffset = CGSizeMake(0, 1);
        statusLabel.text = @"Preview";
        UIBarButtonItem *labelButtonItem = [[UIBarButtonItem alloc] initWithCustomView:statusLabel];

        
        self.items = [NSArray arrayWithObjects:
                      retakeButtonItem,
                      [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                      labelButtonItem,
                      [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease],
                      useButtonItem,
                      nil];

        [retakeButtonItem release];
        [useButtonItem release];        
        [labelButtonItem release];
    }
    
    return self;
}


- (void)dealloc {
    self.statusLabel = nil;
    self.retakeButton = nil;
    self.useButton = nil;
    
    [super dealloc];
}


- (void)retakePicture:(id)sender {
    if(delegate) {
    	[delegate retakePicture];
    }
}


- (void)usePicture:(id)sender {
    if(delegate) {
    	[delegate usePicture];
    }
}


- (void)drawRect:(CGRect)rect {
    [[UIImage imageNamed:@"toolbar-gradient.png"] drawInRect:rect];
}


@end
