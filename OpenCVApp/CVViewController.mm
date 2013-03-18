//
//  CVViewController.m
//  OpenCVApp
//
//  Created by thata on 2013/03/02.
//  Copyright (c) 2013年 chikuwaprog.com. All rights reserved.
//

#import "CVViewController.h"

static NSString *IMAGE_NAME = @"memo.jpg";
//static NSString *IMAGE_NAME = @"neko_tsubaki_blue_car.jpg";

@interface CVViewController ()

@end

@implementation CVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.    
}

- (void)viewDidLayoutSubviews
{
    // デフォルトの画像を表示
    UIImage *image = [UIImage imageNamed:IMAGE_NAME];
    self.imageView.image = image;
    
    [self printSizeOf:image];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

- (UIImage *)monoclo:(UIImage *)image {
    cv::Mat srcMat = [self cvMatFromUIImage:image];
    cv::Mat greyMat;
    cv::cvtColor(srcMat, greyMat, CV_BGR2GRAY);
    UIImage *greyImage = [self UIImageFromCVMat:greyMat];
    return greyImage;
}

- (UIImage *)binalize:(UIImage *)image {
    cv::Mat srcMat = [self cvMatFromUIImage:image];
    cv::Mat greyMat;
    cv::cvtColor(srcMat, greyMat, CV_BGR2GRAY);
    cv::threshold(greyMat, greyMat, 128, 255, CV_THRESH_BINARY);
    UIImage *greyImage = [self UIImageFromCVMat:greyMat];
    return greyImage;
}

- (IBAction)doDidPress:(id)sender {
    UIImage *image = [UIImage imageNamed:IMAGE_NAME];

    UIImage *greyImage = [self binalize:image];
//    UIImage *greyImage = [self monoclo:image];

    self.imageView.image = greyImage;
    
    [self printSizeOf:greyImage];
}

- (void)printSizeOf:(UIImage *)image
{
    NSData *data;
    data = UIImageJPEGRepresentation(image, 0.0);
    NSLog(@"jpeg size: %d", [data length]);

    data = UIImagePNGRepresentation(image);
    NSLog(@"png size: %d", [data length]);
}

@end
