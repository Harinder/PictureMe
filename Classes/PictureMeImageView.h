//
//  PictureMeImageView.h
//  PictureMe
//
//  Created by Jeremy Collins on 12/30/09.
//  Copyright 2009 Beetlebug Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PictureMeImageView : UIView {
    CGRect face;
    UIImage *image;
}


@property (nonatomic, assign) CGRect face;
@property (nonatomic, retain) UIImage *image;


@end
