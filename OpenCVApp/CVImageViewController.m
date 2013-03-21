//
//  CVImageViewController.m
//  OpenCVApp
//
//  Created by thata on 2013/03/21.
//  Copyright (c) 2013年 chikuwaprog.com. All rights reserved.
//

#import "CVImageViewController.h"

@interface CVImageViewController ()

@end

@implementation CVImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    NSData *data = [NSData dataWithContentsOfURL:self.selectedPictureURL];
    UIImage *image = [UIImage imageWithData:data];
    self.imageView.image = image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
