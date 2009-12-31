//
//  PictureMeController.m
//  PictureMe
//
//  Created by Jeremy Collins on 3/30/09.
//  Copyright 2009 Jeremy Collins. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>
#import "UIImage-Additions.h"
#import "UIDevice-Hardware.h"
#import "PictureMeController.h"


extern CGImageRef UIGetScreenImage();
static CvMemStorage *storage = 0;


@implementation PictureMeController


@synthesize camera;
@synthesize model;
@synthesize detecting;


- (void)dealloc {
    self.camera = nil;
    
    [super dealloc];
}


- (void)viewDidLoad {
    self.camera = [[UIImagePickerController alloc] init];
    camera.sourceType = UIImagePickerControllerSourceTypeCamera;
    camera.delegate = self;
    camera.showsCameraControls = NO;
    camera.cameraOverlayView = self.view;
    
    camerabar = [[PictureMeCameraBar alloc] initWithFrame:CGRectMake(0, 480 - 53, 320, 53)];
    camerabar.delegate = self;
    [self.view addSubview:camerabar];
    [camerabar release];
    
    previewbar = [[PictureMePreviewBar alloc] initWithFrame:CGRectMake(320, 480 - 53, 320, 53)];
    previewbar.delegate = self;
    [self.view addSubview:previewbar];
    [previewbar release];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];  
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:@"UIDeviceOrientationDidChangeNotification"
                                               object:nil];    
}


- (void)viewDidAppear:(BOOL)animated {
    [self presentModalViewController:camera animated:NO]; 
    [self startDetection];
}


- (void)imagePickerController:(UIImagePickerController *)picker 
        didFinishPickingImage:(UIImage *)aImage
                  editingInfo:(NSDictionary *)editingInfo {

    [self stopDetection];
    
    image = [aImage retain];
    
    CGImageRef screen = UIGetScreenImage();
    imageView = [[PictureMeImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 427)];
    imageView.image = [[UIImage imageWithCGImage:screen] imageCroppedToRect:CGRectMake(0, 0, 320, 427)];
    imageView.face = face;
    CGImageRelease(screen);
    	
    [self.view addSubview:imageView];
    [imageView release];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5f];
    camerabar.frame = CGRectMake(-320, 480 - 53, 320, 53);
    previewbar.frame = CGRectMake(0, 480 - 53, 320, 53);
    [UIView commitAnimations];
    
}


- (void)savedImage:(UIImage *)aImage didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self retakePicture];
}


- (void)takePicture {
    [camera takePicture];
}


- (void)retakePicture {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:.5f];
    previewbar.frame = CGRectMake(320, 480 - 53, 320, 53);
    camerabar.frame = CGRectMake(0, 480 - 53, 320, 53);
    [UIView commitAnimations];
    
    [imageView removeFromSuperview];
    [image release];

    previewbar.statusLabel.text = @"Preview";
    previewbar.useButton.enabled = YES;
    previewbar.retakeButton.enabled = YES;
    
    [self startDetection];
}


- (void)usePicture {
    previewbar.statusLabel.text = @"Saving...";
    previewbar.useButton.enabled = NO;
    previewbar.retakeButton.enabled = NO;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedImage:didFinishSavingWithError:contextInfo:), nil);
}


#pragma mark Face Detection methods


- (void)deviceOrientationDidChange:(id)ignore {
    UIDevice *device = [UIDevice currentDevice];
    orientation = device.orientation;
}


- (void)detectFaceThread {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self retain];

    self.detecting = YES;
    
    if(self.model == nil) {
        NSString *file = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2.xml" ofType:@"gz"];
        self.model = (CvHaarClassifierCascade *) cvLoad([file cStringUsingEncoding:NSASCIIStringEncoding], 0, 0, 0);
    }
    
    UIDevice *device = [UIDevice currentDevice];
    
    CGImageRef screen = UIGetScreenImage();
    UIImage *viewImage = [UIImage imageWithCGImage:screen];
    CGImageRelease(screen);
    CGRect scaled;
    scaled.size = viewImage.size;
    
    if([device platformType] != UIDevice3GSiPhone) {
        scaled.size.width *= .5;
        scaled.size.height *= .5;
    } else {
        scaled.size.width *= .75;
        scaled.size.height *= .75;
    }
    
    //self.preview = viewImage;
    viewImage = [viewImage scaleImage:scaled];
    
    // Convert to grayscale and equalize.  Helps face detection.
    IplImage *snapshot = [viewImage cvGrayscaleImage];
    IplImage *snapshotRotated = cvCloneImage(snapshot);
    cvEqualizeHist(snapshot, snapshot);
    
    // Rotate image if necessary.  In case phone is being held in 
    // landscape orientation.
    float angle = 0;
    if(orientation == UIDeviceOrientationLandscapeLeft) {
        angle = 90;
    } else if(orientation == UIDeviceOrientationLandscapeRight) {
        angle = -90;
    } 
    
    if(angle != 0) {
        CvPoint2D32f center;
        CvMat *translate = cvCreateMat(2, 3, CV_32FC1);
        cvSetZero(translate);
        center.x = viewImage.size.width / 2;
        center.y = viewImage.size.height / 2;
        cv2DRotationMatrix(center, angle, 1.0, translate);
        cvWarpAffine(snapshot, snapshotRotated, translate, CV_INTER_LINEAR + CV_WARP_FILL_OUTLIERS, cvScalarAll(0));
        cvReleaseMat(&translate);   
    }
    
    storage = cvCreateMemStorage(0);
    
    double t = (double)cvGetTickCount();
    CvSeq* faces = cvHaarDetectObjects(snapshotRotated, self.model, storage,
                                       1.1, 2, CV_HAAR_DO_CANNY_PRUNING,
                                       cvSize(30, 30));
    t = (double)cvGetTickCount() - t;
    
    NSLog(@"Face detection time %gms FOUND(%d)", t/((double)cvGetTickFrequency()*1000), faces->total);
    
    // If a face is found trigger the shutter otherwise perform
    // face detection again.
    if(faces->total > 0) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [NSThread sleepForTimeInterval:1];
        [camera takePicture];
        
	CvRect *r = (CvRect *) cvGetSeqElem(faces, 0);
        
        face.origin.x = (float) r->x;
        face.origin.y = (float) r->y;
        face.size.width = (float) r->width;
        face.size.height = (float) r->height;

        if([device platformType] != UIDevice3GSiPhone) {
            face.size.width /= .5;
            face.size.height /= .5;
            face.origin.x /= .5;
            face.origin.y /= .5;
        } else {
            face.size.width /= .75; face.size.width += 55 * .75;
            face.size.height /= .75; face.size.height += 55 * .75;
            face.origin.x /= .75; face.origin.x += 55 * .75;
            face.origin.y /= .75; face.origin.y += 55 * .75;
        }
        
    } else {
        if(self.detecting) {
            [self performSelectorInBackground:@selector(detectFaceThread) withObject:nil];
        }
    }
    
    cvReleaseImage(&snapshot);
    cvReleaseImage(&snapshotRotated);
    cvReleaseMemStorage(&storage);
    
    [pool release];
    [self release];
}


- (void)startDetection {
    [self performSelectorInBackground:@selector(detectFaceThread) withObject:nil];
}


- (void)stopDetection {
    self.detecting = NO;
}


#pragma mark UINavigationControllerDelegate Methods


- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}


@end
