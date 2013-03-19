//
//  CVImageTableViewController.h
//  OpenCVApp
//
//  Created by thata on 2013/03/18.
//  Copyright (c) 2013年 chikuwaprog.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CVImageTableViewController : UITableViewController
- (IBAction)takePhoto:(id)sender;

@end

void UIImageWriteGrayscaleToDocuments(UIImage *image, NSString *fileName, id target, SEL selector);
void test(UIImage *img);
