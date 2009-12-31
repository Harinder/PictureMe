//
//  PictureMeController.h
//  PictureMe
//
//  Created by Jeremy Collins on 3/30/09.
//  Copyright 2009 Jeremy Collins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage-Additions.h"
#import "PictureMeCameraBar.h"
#import "PictureMePreviewBar.h"
#import "PictureMeImageView.h"


@interface PictureMeController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIDeviceOrientation orientation;
    UIImagePickerController *camera;
    PictureMeImageView *imageView;
    UIImage *image;
    CGRect face;
    
    CvHaarClassifierCascade *model;
    
    PictureMeCameraBar *camerabar;
    PictureMePreviewBar *previewbar;
    
    BOOL detecting;
}


@property (nonatomic, retain) UIImagePickerController *camera;
@property (nonatomic, assign) CvHaarClassifierCascade *model;
@property (assign) BOOL detecting;


- (void)savedImage:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;

- (void)takePicture;

- (void)retakePicture;

- (void)usePicture;

- (void)startDetection;

- (void)stopDetection;


@end
