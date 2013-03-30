//
//  CVImageViewController.m
//  OpenCVApp
//
//  Created by thata on 2013/03/21.
//  Copyright (c) 2013年 chikuwaprog.com. All rights reserved.
//

#import "CVImageViewController.h"
#import "CommonCrypto/CommonDigest.h"
#import "EvernoteSDK.h"

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

    // イメージ
    NSData *data = [NSData dataWithContentsOfURL:self.selectedPictureURL];
    UIImage *image = [UIImage imageWithData:data];
    self.imageView.image = image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)uploadDidPress:(id)sender {
    [self sendEvernote:@"hello" withUIImage:self.imageView.image];
}

- (void)sendEvernote:(NSString *)sendText withUIImage:(UIImage *)sendImage
{
    NSString *EVERNOTE_HOST = @"sandbox.evernote.com";
    NSString *CONSUMER_KEY = @"htkymtks";
    NSString *CONSUMER_SECRET = @"10b3535732ca1457";
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST
                              consumerKey:CONSUMER_KEY
                           consumerSecret:CONSUMER_SECRET];
    EvernoteSession *session = [EvernoteSession sharedSession];
    if (session.isAuthenticated) {
        // sendTextの改行コード\nを<br/>にする＆一行目をタイトルにする
        NSArray *textLines = [sendText componentsSeparatedByString:@"\n"];
        NSString *title = [[NSString alloc] initWithFormat:@"%@", [textLines objectAtIndex:0]];
        NSMutableString *contentBody = [NSMutableString string];
        for (NSString* line in textLines) {
            [contentBody appendFormat:@"%@<br/>", line];
        }
        NSArray *tagNames = [NSArray arrayWithObject:@"hoge"];
        [self evernoteCreateNote:title withUIImage:sendImage withContentBody:contentBody withTagNames:tagNames];
    } else {
        // 認証 EvernoteSessionクラスが勝手にモーダルなWebViewを作ってEvernoteのサイトで認証、完了したら発行されるTokenを勝手にどこかに保存するところまでやってくれる
        [session authenticateWithViewController:self
                              completionHandler:^(NSError *error) {
                                  if (error || !session.isAuthenticated) {
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                      message:@"Could not authenticate"
                                                                                     delegate:nil
                                                                            cancelButtonTitle:@"OK"
                                                                            otherButtonTitles:nil];
                                      [alert show];
                                  } else {
                                      // 投稿再試行
                                      [self sendEvernote:sendText withUIImage:sendImage];
                                  }
                              }];
    }
}

// 認証済みアカウントのデフォルトのNotebookに新たなNoteを追加するためのメソッド
- (void)evernoteCreateNote:(NSString *)title
               withUIImage:(UIImage *)sendImage
           withContentBody:(NSMutableString *)contentBody
              withTagNames:(NSArray *)tagNames
{
    // create image hash and resource from sendImage
    NSData* sendData = [[NSData alloc] initWithData:UIImagePNGRepresentation(sendImage)];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5([sendData bytes], [sendData length], digest);
    char md5cstring[CC_MD5_DIGEST_LENGTH*2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        sprintf(md5cstring+i*2, "%02x", digest[i]);
    }
    NSString *hash = [NSString stringWithCString:md5cstring encoding:NSASCIIStringEncoding];
    EDAMData * imageData = [[EDAMData alloc] initWithBodyHash:[hash dataUsingEncoding: NSASCIIStringEncoding]
                                                         size:[sendData length]
                                                         body:sendData];
    EDAMResourceAttributes * imageAttributes = [[EDAMResourceAttributes alloc] init];
    EDAMResource * imageResource  = [[EDAMResource alloc]init];
    [imageResource setMime:@"image/png"];
    [imageResource setData:imageData];
    [imageResource setAttributes:imageAttributes];
    
    // create content xml from contentBody
    NSMutableString *xmlContents = [NSMutableString string];
    [xmlContents setString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
    [xmlContents appendString:@"<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml.dtd\">"];
    [xmlContents appendString:@"<en-note>"];
    [xmlContents appendString:contentBody];
    [xmlContents appendFormat:@"<br/><en-media type=\"image/png\" hash=\"%@\"/><br/>", hash];
    [xmlContents appendString:@"</en-note>"];
    
    // create note obj
    EDAMNoteAttributes *newNoteAttributes = [[EDAMNoteAttributes alloc]init];
    EDAMNote *newNote = [[EDAMNote alloc] init];
    [newNote setTitle:title];
    [newNote setContent:xmlContents];
    [newNote setTagNames:[NSMutableArray arrayWithArray:tagNames]];
    [newNote setAttributes:newNoteAttributes];
    [newNote setCreated:(long long)[[NSDate date] timeIntervalSince1970] * 1000];
    [newNote setResources:[NSArray arrayWithObject:imageResource]];
    
    // create note
    EvernoteNoteStore *noteStore = [EvernoteNoteStore noteStore];
    [noteStore createNote:newNote
                  success:^(EDAMNote *note) {
                      NSLog(@"createNote succeed");
                  }
                  failure:^(NSError *error) {
                      NSLog(@"createNote error %@", error);
                  }];
}

@end
