//
//  CVImageTableViewController.m
//  OpenCVApp
//
//  Created by thata on 2013/03/18.
//  Copyright (c) 2013年 chikuwaprog.com. All rights reserved.
//

#import "CVImageTableViewController.h"
#import "CVImageViewController.h"
#import "jpeglib.h"

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
//    NSData *data = UIImageJPEGRepresentation(image, 0.0);
    
    // Documentsディレクトリへ保存する
    NSString *fileName;
    fileName = [NSString stringWithFormat:@"%@.jpg",
                [[NSUUID UUID] UUIDString]];
    UIImageWriteGrayscaleToDocuments(image, fileName, self.tableView, @selector(reloadData));

    fileName = [NSString stringWithFormat:@"%@.jpg",
                [[NSUUID UUID] UUIDString]];
    UIImageWriteToDocuments(image, fileName, self.tableView, @selector(reloadData));

    
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

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        CVImageViewController *viewController;
        viewController = [segue destinationViewController];
        viewController.selectedPictureURL = [[self pictures] objectAtIndex:self.tableView.indexPathForSelectedRow.row];
    }
}

@end

NSData *rawData(UIImage *image)
{
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    
    unsigned char *rawData = (unsigned char*) calloc(height * width * 4, sizeof(unsigned char));
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rawData,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast |
                                                 kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    NSData *result = [NSData dataWithBytes:rawData
                                    length:height * width * 4 * sizeof(unsigned char)];
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(rawData);
    
    return result;
}

void UIImageWriteGrayscaleToDocuments(UIImage *image, NSString *fileName, id completionTarget, SEL completionSelector)
{
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    
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
    
    /* JPEGへ書き出し */
    NSData *d = rawData(image);
    unsigned char *rawData = (unsigned char*)[d bytes];
    
    JSAMPARRAY img = (JSAMPARRAY) malloc(sizeof(JSAMPROW) * height);
    
    for (int y = 0; y < height; y++) {
        img[y] = (JSAMPROW) malloc(sizeof(JSAMPLE) * width);
        for (int x = 0; x < width; x++) {
            int byteIndex = (bytesPerRow * y) + x * bytesPerPixel;
            // グレイスケール化
            // 参考: http://en.wikipedia.org/wiki/Grayscale#Converting_color_to_grayscale
            unsigned char gray = rawData[byteIndex] * 0.3 + rawData[byteIndex + 1] * 0.59 + rawData[byteIndex + 2] * 0.11;
            img[y][x] = gray;
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

void UIImageWriteToDocuments(UIImage *image, NSString *fileName, id completionTarget, SEL completionSelector)
{
    NSData *data = UIImageJPEGRepresentation(image, 0.75);

    /* 出力ファイルの設定 */
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *documentRoot = [[fm URLsForDirectory:NSDocumentDirectory
                                      inDomains:NSUserDomainMask] objectAtIndex:0];
    NSURL *url = [documentRoot URLByAppendingPathComponent:fileName];
    
    [data writeToURL:url atomically:YES];

    // completionHandlerを実行
    [completionTarget performSelector:completionSelector withObject:nil afterDelay:0.0f];
}

