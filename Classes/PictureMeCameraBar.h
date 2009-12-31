//
//  PMToolbar.h
//  PictureMe
//
//  Created by Jeremy Collins on 12/29/09.
//  Copyright 2009 Beetlebug Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PictureMeController;


@interface PictureMeCameraBar : UIToolbar {
    PictureMeController *delegate;
}


@property (nonatomic, assign) PictureMeController *delegate;


@end
