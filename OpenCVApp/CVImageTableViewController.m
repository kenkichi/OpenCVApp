//
//  CVImageTableViewController.m
//  OpenCVApp
//
//  Created by thata on 2013/03/18.
//  Copyright (c) 2013年 chikuwaprog.com. All rights reserved.
//

#import "CVImageTableViewController.h"

@interface CVImageTableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation CVImageTableViewController

- (IBAction)takePhoto:(id)sender {
    // カメラを起動
    UIImagePickerController *imagePicker;
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
}

- (NSArray *)pictures
{
    NSArray *dirs = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *documentsDir = [[fm URLsForDirectory:NSDocumentDirectory
                                      inDomains:NSUserDomainMask] objectAtIndex:0];
    dirs = [fm contentsOfDirectoryAtURL:documentsDir
             includingPropertiesForKeys:nil
                                options:0
                                  error:nil];
    return dirs;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // 撮影した画像を取得し、
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // カメラロールに保存する
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    NSUUID *uuid = [NSUUID UUID];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [uuid UUIDString]];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *documentRoot = [[fm URLsForDirectory:NSDocumentDirectory
                             inDomains:NSUserDomainMask] objectAtIndex:0];
    NSURL *url = [documentRoot URLByAppendingPathComponent:fileName];
    [data writeToURL:url atomically:YES];

    // カメラを閉じる
    [self dismissViewControllerAnimated:YES completion:nil];

    // 別スレッドでリロード
    NSOperationQueue *q = [NSOperationQueue mainQueue];
    [q addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self pictures] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSURL *imageURL = [[self pictures] objectAtIndex:indexPath.row];

    NSData *data = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = [UIImage imageWithData:data];
    cell.imageView.image = image;
    cell.textLabel.text = [NSString stringWithFormat:@"%d", [data length]];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSFileManager *fm = [NSFileManager defaultManager];
        NSURL *imageURL = [[self pictures] objectAtIndex:indexPath.row];
        [fm removeItemAtURL:imageURL error:nil];
        // ファイルの削除が終わった頃にテーブルをリロード
        NSOperationQueue *q = [NSOperationQueue mainQueue];
        [q addOperationWithBlock:^{
            [self.tableView reloadData];
        }];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
