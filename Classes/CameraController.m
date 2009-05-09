//
//  CameraController.m
//  TouchCamera
//
//  Created by Jeremy Collins on 3/11/09.
//  Copyright 2009 Jeremy Collins. All rights reserved.
//

#import "CameraController.h"
#import "RedactedCameraController.h"
#import <QuartzCore/QuartzCore.h> 
#import "AudioToolbox/AudioServices.h"

extern CGImageRef UIGetScreenImage();
static CvMemStorage *storage = 0;
static CameraController *instance = nil;

@implementation CameraController

@synthesize faceTimer;
@synthesize previewTimer;
@synthesize model;

+ (CameraController *)instance {
	@synchronized(self) {
        if (instance == nil) {
            instance = [[self alloc] init];
            
            if([instance respondsToSelector:@selector(isViewLoaded)]) {
                [instance release];
                instance = [[RedactedCameraController alloc] init];
            }
            
            // Listen for device orientation changes so we can rotate the 
            // image accordingly before detecting faces.
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];  
            [[NSNotificationCenter defaultCenter] addObserver:instance
                                                     selector:@selector(deviceOrientationDidChange:)
                                                         name:@"UIDeviceOrientationDidChangeNotification"
                                                       object:nil]; 
        }
    }
    return instance;
}

-(void)setFaceTimer:(NSTimer *)timer {
	if (faceTimer != timer) {
		[faceTimer invalidate];
		[faceTimer release];
		faceTimer = [timer retain];
	}
}

-(void)setPreviewTimer:(NSTimer *)timer {
    if (previewTimer != timer) {
        [previewTimer invalidate];
        [previewTimer release];
        previewTimer = [timer retain];
    }
}

- (void)deviceOrientationDidChange:(id)ignore {
    UIDevice *device = [UIDevice currentDevice];
    o = device.orientation;
}

- (void)triggerShutter {
    UIButton *button = [[[[[[[[[[[[self.view subviews] objectAtIndex:0]
                                             subviews] objectAtIndex:0]
                                             subviews] objectAtIndex:0]
                                             subviews] objectAtIndex:3]
                                             subviews] objectAtIndex:2]
                                             subviews] objectAtIndex:1];
    [button sendActionsForControlEvents:UIControlEventTouchUpInside];  
}

- (void)detectFaceThread {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [self retain];
        
    self.faceTimer = nil;
    
    if(self.model == nil) {
        NSString *file = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2.xml" ofType:@"gz"];
        self.model = (CvHaarClassifierCascade *) cvLoad([file cStringUsingEncoding:NSASCIIStringEncoding], 0, 0, 0);
    }
    
    CGImageRef screen = UIGetScreenImage();
    UIImage *viewImage = [UIImage imageWithCGImage:screen];
    CGImageRelease(screen);
    CGRect scaled;
    scaled.size = viewImage.size;
    scaled.size.width *= .5;
    scaled.size.height *= .5;
    viewImage = [viewImage scaleImage:scaled];
    
    // Convert to grayscale and equalize.  Helps face detection.
    IplImage *snapshot = [viewImage cvGrayscaleImage];
    IplImage *snapshotRotated = cvCloneImage(snapshot);
    cvEqualizeHist(snapshot, snapshot);
    
    // Rotate image if necessary.  In case phone is being held in 
    // landscape orientation.
    float angle = 0;
    if(o == UIDeviceOrientationLandscapeLeft) {
        angle = 90;
    } else if(o == UIDeviceOrientationLandscapeRight) {
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
        [self triggerShutter];
    } else {
        [self performSelectorOnMainThread:@selector(reschedule) withObject:nil waitUntilDone:NO];
    }
    
    cvReleaseImage(&snapshot);
    cvReleaseImage(&snapshotRotated);
    cvReleaseMemStorage(&storage);
    
    [pool release];
    [self release];
}

-(void)reschedule {
    if(!isPreview && isDisplayed) {
        self.faceTimer = [NSTimer scheduledTimerWithTimeInterval:.10
                                                          target:self 
                                                        selector:@selector(detectFace) 
                                                        userInfo:nil repeats:YES];    
    }
}

-(void)detectFace {
    self.faceTimer = nil;
    [self performSelectorInBackground:@selector(detectFaceThread) withObject:nil];    
}

-(void)previewCheck {
    UIView *preview;
    // Preview view path is /0/0/0/2, by default without a subview
    // if it has a subview, preview image is showing, so fix transform
    //        
    preview = [[[[[[[[self.view subviews] objectAtIndex:0]
                                subviews] objectAtIndex:0]
                                subviews] objectAtIndex:0]
                                subviews] objectAtIndex:2];
    
    if ([preview.subviews count] != 0 && !isPreview) {
        isPreview = YES;
    }            
}

- (void)setup { 
    
    // Hide the top bar that says "Take Picture" to give more room for
    // faces.  Also add targets for TouchUpInside events on the "Cancel"
    // and shutter buttons.
    UIImageView *overlay = [[[[[[[[[[self.view subviews] objectAtIndex:0]
                                               subviews] objectAtIndex:0]
                                               subviews] objectAtIndex:0]
                                               subviews] objectAtIndex:3]
                                               subviews] objectAtIndex:0];  
    
    UILabel *label = [[[[[[[[[[self.view subviews] objectAtIndex:0]
                                         subviews] objectAtIndex:0]
                                         subviews] objectAtIndex:0]
                                         subviews] objectAtIndex:3]
                                         subviews] objectAtIndex:1];
    
    UIButton *button = [[[[[[[[[[[[self.view subviews] objectAtIndex:0]
                                             subviews] objectAtIndex:0]
                                             subviews] objectAtIndex:0]
                                             subviews] objectAtIndex:3]
                                             subviews] objectAtIndex:2]
                                             subviews] objectAtIndex:0];
    
    [button addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *captureButton = [[[[[[[[[[[[self.view subviews] objectAtIndex:0]
                                                    subviews] objectAtIndex:0]
                                                    subviews] objectAtIndex:0]
                                                    subviews] objectAtIndex:3]
                                                    subviews] objectAtIndex:2]
                                                    subviews] objectAtIndex:1];
    
    [captureButton addTarget:self action:@selector(captureButtonAction:) forControlEvents:UIControlEventTouchUpInside];        
    
    label.hidden = YES;
    overlay.hidden = YES;
}

- (void)viewDidAppear: (BOOL)animated {
	[super viewDidAppear:animated];
    
    isPreview = NO;
    isDisplayed = YES;
    
    self.faceTimer = [NSTimer scheduledTimerWithTimeInterval:.25 
                                                      target:self 
                                                    selector:@selector(detectFace) 
                                                    userInfo:nil repeats:YES];

    self.previewTimer = [NSTimer scheduledTimerWithTimeInterval:.25
                                                         target:self
                                                       selector:@selector(previewCheck)
                                                       userInfo:nil repeats:YES];    
        
    if(self.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self setup];
    }	
}

- (void)captureButtonAction:(id)sender {
    self.faceTimer = nil;
}

- (void)cancelButtonAction:(id)sender {
	if (isPreview) {
        isPreview = NO;
        [self performSelectorOnMainThread:@selector(reschedule) withObject:nil waitUntilDone:YES];        
    } else {
        self.faceTimer = nil;
        [self dismissModalViewControllerAnimated:YES];        
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.faceTimer = nil;
    self.previewTimer = nil;
    isDisplayed = NO;
}

-(void) dealloc {
    self.faceTimer = nil;
    self.previewTimer = nil;
    
	[super dealloc];
}

@end
