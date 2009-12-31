//
//  PictureMePreviewBar.h
//  PictureMe
//
//  Created by Jeremy Collins on 12/30/09.
//  Copyright 2009 Beetlebug Software, LLC. All rights reserved.
//


#import <UIKit/UIKit.h>


@class PictureMeController;


@interface PictureMePreviewBar : UIToolbar {
    PictureMeController *delegate;
    
    UILabel *statusLabel;
    UIButton *retakeButton;
    UIButton *useButton;
}


@property (nonatomic, assign) PictureMeController *delegate;
@property (nonatomic, retain) UILabel *statusLabel;
@property (nonatomic, retain) UIButton *retakeButton;
@property (nonatomic, retain) UIButton *useButton;


@end
