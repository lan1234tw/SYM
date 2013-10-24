//
//  com_symViewController.m
//  SYM
//
//  Created by HsiuYi on 13/9/17.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "com_symViewController.h"
#import "HTTPDownloader.h"
#import "stageViewController.h"

#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>

#import "ZipArchive.h"
#import "com_symAppDelegate.h"

#import "ContentBase.h"
#import "ContentItem.h"

@interface com_symViewController ()
@end

@implementation com_symViewController
@synthesize itemTableView = _itemTableView;

#pragma mark - Private method


#pragma mark - Public method
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if(nil == items) {
        items =[[NSMutableArray alloc] init];
    } // if
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell =nil;
    cell =[tableView dequeueReusableCellWithIdentifier:@"itemCell"];
    
    NSDictionary* dic =nil;
    dic =items[indexPath.row];
    
    cell.textLabel.text =dic[@"archivePath"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(nil != items) {
        NSLog(@"items count : %d", [items count]);
        return [items count];
    } // if
    else {
        return 0;
    } // else
}


#pragma mark - UI Event Handler
/*
- (IBAction)btnTouched:(id)sender {
    NSString* url =@"http://localhost:8080/symBack/json.txt";
    
    HTTPDownloader* downloader =nil;
    downloader =[[HTTPDownloader alloc] init];
    
    items =[downloader getList:url];
    NSLog(@"items count : %d", [items count]);
    [self.itemTableView reloadData];
}

- (IBAction)testZip_touched:(id)sender {
    NSURL* url =nil;
    url =[NSURL URLWithString:@"http://localhost:8080/symBack/dw1.zip"];
    
    NSData* data =nil;
    data =[NSData dataWithContentsOfURL:url];
    
    if(nil == data) {
        NSLog(@"無法讀取資料");
        return;
    } // if
    
    NSFileManager* fileManager =nil;
    fileManager =[[NSFileManager alloc] init];
    
    NSArray *urls =NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if(0 >= urls.count) {
        NSLog(@"找不到Cache的folder");
        return;
    } // if
    
    NSString* filePath =[[NSString alloc] initWithString:urls[0]];
    filePath =[filePath stringByAppendingPathComponent:[url lastPathComponent]];
    NSLog(@"寫入路徑及檔名：%@", filePath);
    
    BOOL b =[fileManager createFileAtPath:filePath contents:data attributes:nil];
    if(NO == b) {
        NSLog(@"無法寫入下載檔案");
        return;
    } // if
    
    NSString* fileFullName =[url lastPathComponent];
    NSString* fileName =[fileFullName stringByDeletingPathExtension];
    NSLog(@"主檔名：%@", fileName);
    
    NSString* ttt =urls[0];
    
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    b =[zipArchive UnzipOpenFile:filePath];
    if(NO == b) {
        NSLog(@"無法開啓壓縮檔案");
        return;
    } // if
        
    b =[zipArchive UnzipFileTo:ttt overWrite:YES];
    if(NO == b) {
        NSLog(@"無法解壓縮下載檔案");
        return;
    } // if
    
    [zipArchive UnzipCloseFile];
    
    ttt =[ttt stringByAppendingPathComponent:fileName];
    
    NSLog(@"%@", ttt);
    NSDirectoryEnumerator *dirEnum =[fileManager enumeratorAtPath:ttt];
    
    // 把檔案列示出來看看是不是正常
    NSString *file;
    while ((file = [dirEnum nextObject])) {
        NSLog(@">>> %@", file);
    } // while
}

- (IBAction)testMac_touched:(id)sender {
  // [self insertData];
  // [self testQueryData];
  
  HTTPDownloader* downloader =nil;
  downloader =[[HTTPDownloader alloc] init];
  
  // [downloader downloadItem];
}
*/
/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if([segue.identifier isEqualToString:@"toPageViewController"]) {
    UIPageViewController* pageViewController =nil;
    pageViewController =(UIPageViewController*)[segue destinationViewController];
    
    PageModel* model =nil;
    model =(PageModel*)pageViewController.dataSource;
    
    id returnVal =[self.storyboard instantiateViewControllerWithIdentifier:@"ID_StageViewController"];
    StageViewController* viewController =nil;
    viewController =(StageViewController*)returnVal;
    
    [pageViewController setViewControllers:@[viewController]
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:YES
                                completion:nil];
  } // if
}
*/

#pragma mark - other
// 寫入測試資料
- (void)insertData {
  com_symAppDelegate* appDelegate =nil;
  appDelegate =(com_symAppDelegate*)[UIApplication sharedApplication].delegate;
  
  ContentBase* base =nil;
  base =[NSEntityDescription insertNewObjectForEntityForName:@"ContentBase"
                             inManagedObjectContext:appDelegate.managedObjectContext];
  
  base.pathBase =@"dw1";
  
  ///MARK:這段code用來測試使用NSString取代NSDate的話，是否仍然可以適用於區間查詢
  base.startDate =@"2013/10/01";
  base.endDate =@"2013/10/23";
  
  ContentItem* item =nil;
  item =[NSEntityDescription insertNewObjectForEntityForName:@"ContentItem"
                             inManagedObjectContext:appDelegate.managedObjectContext];
  
  item.base =base;
  item.path =@"a1.jpg";
  
  // [base addItemsObject:item];
  
  NSError* err;
  [appDelegate.managedObjectContext save:&err];
  if(nil != err) {
    NSLog(@"%@", err.debugDescription);
  } // if
}


// 測試查詢資料
- (void)testQueryData {
  com_symAppDelegate* appDelegate =nil;
  appDelegate =(com_symAppDelegate*)[UIApplication sharedApplication].delegate;
  
  NSPredicate* predicate =[NSPredicate predicateWithFormat:@"endDate >= %@", @"2013/10/20"];
  
  NSEntityDescription* desc =nil;
  desc =[NSEntityDescription entityForName:@"ContentBase" inManagedObjectContext:appDelegate.managedObjectContext];
  
  NSFetchRequest* req =nil;
  req =[[NSFetchRequest alloc] init];
  [req setEntity:desc];
  [req setPredicate:predicate];
  
  NSError* err =nil;
  NSArray* result =nil;
  result =[appDelegate.managedObjectContext executeFetchRequest:req error:&err];
  if(nil != err) {
    NSLog(@"%@", err.debugDescription);
    return;
  } // if
  
  NSLog(@"查詢結果無錯誤，找到資料筆數:%d", result.count);
  
  if(0 < result.count) {
    ContentBase* base =result[0];
    NSLog(@"%@", base.pathBase);
    NSLog(@"%@", ((ContentItem*)(base.items[0])).path);
  } // if
}

@end
