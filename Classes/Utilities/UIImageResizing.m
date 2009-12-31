//
//  UIImageResizing.m
//
//  Created by Jeremy Collins on 2/24/09.
//  Copyright 2009 Jeremy Collins. All rights reserved.
//


#import "UIImageResizing.h"


@implementation UIImage (Resizing)


- (UIImage *)scaleImage:(CGRect)rect {
    
    CGImageRef imgRef = self.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > rect.size.width || height > rect.size.height) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = rect.size.height;
            bounds.size.height = round(bounds.size.width / ratio);
        } else {
            bounds.size.height = rect.size.width;
            bounds.size.width = round(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
        
    UInt8 *pixelData = (UInt8 *) malloc(bounds.size.width * bounds.size.height * 4);
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 bounds.size.width, 
                                                 bounds.size.height, 8, 
                                                 bounds.size.width * 4,
                                                 colorspace,
                                                 kCGImageAlphaNoneSkipLast);        
    
    CGContextScaleCTM(context, scaleRatio, scaleRatio);
    //CGContextTranslateCTM(context, 0, -height);
        
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);

    CGContextRelease(context);
    CGColorSpaceRelease(colorspace);
    free(pixelData);
    
    UIImage *imageCopy = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    [imageCopy autorelease];
    
    return imageCopy;
}


- (UIImage *) imageCroppedToRect:(CGRect)cropRect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], cropRect);
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return image;
}

@end
