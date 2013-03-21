//
//  CVImageViewController.h
//  OpenCVApp
//
//  Created by thata on 2013/03/21.
//  Copyright (c) 2013年 chikuwaprog.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CVImageViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSURL *selectedPictureURL;
@end
