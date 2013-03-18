//
//  CVImageTableViewController.m
//  OpenCVApp
//
//  Created by thata on 2013/03/18.
//  Copyright (c) 2013年 chikuwaprog.com. All rights reserved.
//

#import "CVImageTableViewController.h"
#import "jpeglib.h"

@interface CVImageTableViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation CVImageTableViewController

- (void)libjpeg_test
{
    /* JPEGオブジェクト, エラーハンドラの確保 */
    struct jpeg_compress_struct cinfo;
    struct jpeg_error_mgr jpeg_err;
    
    /* エラーハンドラにデフォルト値を設定 */
    cinfo.err = jpeg_std_error(&jpeg_err);
    
    /* JPEGオブジェクトの初期化 */
    jpeg_create_compress(&cinfo);
    
    /* 出力ファイルの設定 */
    NSUUID *uuid = [NSUUID UUID];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [uuid UUIDString]];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *documentRoot = [[fm URLsForDirectory:NSDocumentDirectory
                                      inDomains:NSUserDomainMask] objectAtIndex:0];
    NSURL *url = [documentRoot URLByAppendingPathComponent:fileName];
    NSString *path = [url path];
    const char *filename = [path cStringUsingEncoding:NSUTF8StringEncoding];
    FILE *fp = fopen(filename, "wb");
    if (fp == NULL) {
        fprintf(stderr, "cannot open %s\n", filename);
        exit(EXIT_FAILURE);
    }
    jpeg_stdio_dest(&cinfo, fp);
    
    /* 画像のパラメータの設定 */
    int width = 256;
    int height = 256;
    
    cinfo.image_width = width;
    cinfo.image_height = height;
    cinfo.input_components = 1;
    cinfo.in_color_space = JCS_GRAYSCALE;
//    cinfo.input_components = 3;
//    cinfo.in_color_space = JCS_RGB;
    jpeg_set_defaults(&cinfo);
    jpeg_set_quality(&cinfo, 10, TRUE);
    
    /* 圧縮開始 */
    jpeg_start_compress(&cinfo, TRUE);
    
    /* RGB値の設定 */
    JSAMPARRAY img = (JSAMPARRAY) malloc(sizeof(JSAMPROW) * height);
    for (int i = 0; i < height; i++) {
        img[i] = (JSAMPROW) malloc(sizeof(JSAMPLE) * width);
        for (int j = 0; j < width; j++) {
            img[i][j] = i;
        }
    }
    /* 書き込む */
    jpeg_write_scanlines(&cinfo, img, height);
    
    /* 圧縮終了 */
    jpeg_finish_compress(&cinfo);
    
    /* JPEGオブジェクトの破棄 */
    jpeg_destroy_compress(&cinfo);
    
    for (int i = 0; i < height; i++) {
        free(img[i]);
    }
    free(img);
    fclose(fp);
    
    // 別スレッドでリロード
    NSOperationQueue *q = [NSOperationQueue mainQueue];
    [q addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

- (IBAction)takePhoto:(id)sender {
    // カメラを起動
    UIImagePickerController *imagePicker;
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker
                       animated:YES
                     completion:nil];
//    [self libjpeg_test];
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
//    NSData *data = UIImageJPEGRepresentation(image, 0.0);
    
    // Documentsディレクトリへ保存する
    NSUUID *uuid = [NSUUID UUID];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [uuid UUIDString]];
//    NSFileManager *fm = [NSFileManager defaultManager];
//    NSURL *documentRoot = [[fm URLsForDirectory:NSDocumentDirectory
//                             inDomains:NSUserDomainMask] objectAtIndex:0];
//    NSURL *url = [documentRoot URLByAppendingPathComponent:fileName];
//    [data writeToURL:url atomically:YES];
    UIImageWriteGrayscaleToDocuments(image, fileName, self.tableView, @selector(reloadData));
    
    // カメラを閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
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

void UIImageWriteGrayscaleToDocuments(UIImage *image, NSString *fileName, id completionTarget, SEL completionSelector)
{    
    /* 画像のパラメータの設定 */
    int width = 256;
    int height = 256;
    
    /* JPEGオブジェクト, エラーハンドラの確保 */
    struct jpeg_compress_struct cinfo;
    struct jpeg_error_mgr jpeg_err;
    
    /* エラーハンドラにデフォルト値を設定 */
    cinfo.err = jpeg_std_error(&jpeg_err);
    
    /* JPEGオブジェクトの初期化 */
    jpeg_create_compress(&cinfo);
    
    /* 出力ファイルの設定 */
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *documentRoot = [[fm URLsForDirectory:NSDocumentDirectory
                                      inDomains:NSUserDomainMask] objectAtIndex:0];
    NSURL *url = [documentRoot URLByAppendingPathComponent:fileName];
    NSString *path = [url path];
    const char *filename = [path cStringUsingEncoding:NSUTF8StringEncoding];
    FILE *fp = fopen(filename, "wb");
    if (fp == NULL) {
        fprintf(stderr, "cannot open %s\n", filename);
        exit(EXIT_FAILURE);
    }
    jpeg_stdio_dest(&cinfo, fp);
    
    cinfo.image_width = width;
    cinfo.image_height = height;
    cinfo.input_components = 1;
    cinfo.in_color_space = JCS_GRAYSCALE;
    //    cinfo.input_components = 3;
    //    cinfo.in_color_space = JCS_RGB;
    jpeg_set_defaults(&cinfo);
    jpeg_set_quality(&cinfo, 10, TRUE);
    
    /* 圧縮開始 */
    jpeg_start_compress(&cinfo, TRUE);
    
    /* RGB値の設定 */
    JSAMPARRAY img = (JSAMPARRAY) malloc(sizeof(JSAMPROW) * height);
    for (int i = 0; i < height; i++) {
        img[i] = (JSAMPROW) malloc(sizeof(JSAMPLE) * width);
        for (int j = 0; j < width; j++) {
            img[i][j] = i;
        }
    }
    
    /* 書き込む */
    jpeg_write_scanlines(&cinfo, img, height);
    
    /* 圧縮終了 */
    jpeg_finish_compress(&cinfo);
    
    /* JPEGオブジェクトの破棄 */
    jpeg_destroy_compress(&cinfo);
    
    for (int i = 0; i < height; i++) {
        free(img[i]);
    }
    free(img);
    fclose(fp);
    
    // completionHandlerを実行
    [completionTarget performSelector:completionSelector withObject:nil afterDelay:0.0f];
}