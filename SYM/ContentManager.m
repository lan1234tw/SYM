//
//  ContentManager.m
//  SYM
//
//  Created by HsiuYi on 2013/11/20.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "ContentManager.h"
#import "DownloadTask.h"
#import "Directories.h"


@interface ContentManager() {
  NSManagedObjectContext* _context;
  NSManagedObjectModel* _objectModel;
  NSPersistentStoreCoordinator* _coordinator;
  
  NSMutableData* buffer;
  long long expectedContentLength; // 檔案長度
  long long receivedLength; // 已接收到的資料長度
}

@end

@implementation ContentManager
@synthesize requestTracking = _requestTracking, queue = _queue;

+ (ContentManager*)instance {
  static ContentManager* _instance =nil;
  static dispatch_once_t predicate;
  
  dispatch_once(&predicate, ^{
    _instance =[[ContentManager alloc] init];
  });
  
  return _instance;
}

#pragma mark - Private Method
- (NSData*)loadItem:(NSString*)url paramName:(NSString*)name paramValue:(NSString*)value {
  NSMutableString *post = [[NSMutableString alloc] init];
  if(nil != name && nil != value) {
    [post appendString:name];
    [post appendString:@"="];
    [post appendString:value];
  } // if
  
  NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
  NSString *postLength = [NSString stringWithFormat:@"%lul", [postData length]];
  
  NSString* encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:
                          NSASCIIStringEncoding];
  
  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
  [request setURL:[NSURL URLWithString:encodedUrl]];
  [request setHTTPMethod:@"POST"];
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:postData];
  
  if(YES == [NSURLConnection canHandleRequest:request]) {
    NSData* data =nil;
    NSURLResponse* response =nil;
    NSError* err;
    data =[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    
    // 轉型為NSHTTPURLResponse以便取得狀態碼
    if(YES == [response isKindOfClass:NSHTTPURLResponse.class]) {
      NSHTTPURLResponse* httpResponse =nil;
      httpResponse =(NSHTTPURLResponse*)response;
    } // if
    
    if(nil != err) {
      NSLog(@"%@", err.debugDescription);
      return nil;
    } // if
    else {
      return data;
    } // else
  } // if
  
  else {
    return nil;
  } // else
}

- (NSManagedObjectModel*)managedObjectModel {
  if(nil != _objectModel) {
    return _objectModel;
  } // if
  
  // NSURL* modelURL =[[NSBundle mainBundle] URLForResource:@"ContentModel" withExtension:@"momd"];
  // _objectModel =[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
  
  _objectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
  return _objectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
  if(nil != _coordinator) {
    return _coordinator;
  } // if
  
  if (![NSThread currentThread].isMainThread) {
    dispatch_sync(dispatch_get_main_queue(), ^{
      [self persistentStoreCoordinator];
    });
    return _coordinator;
  } // if
  
  NSURL* storeURL =[[Directories.instance documentDirectory]
                    URLByAppendingPathComponent:@"ContentModel.sqlite"];
  
  NSDictionary* fileAttributes =[NSDictionary
                                 dictionaryWithObject:NSFileProtectionCompleteUntilFirstUserAuthentication
                                 forKey:NSFileProtectionKey];
  
  NSError* error =nil;
  [[NSFileManager defaultManager] setAttributes:fileAttributes ofItemAtPath:storeURL.path error:&error];
  if(nil != error) {
    NSLog(@"");
  } // if
  
  if(nil == _objectModel) {
    [self managedObjectModel];
  } // if
  
  _coordinator =[[NSPersistentStoreCoordinator alloc]
                 initWithManagedObjectModel:[self managedObjectModel]];
  
  if(nil == [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                          configuration:nil URL:storeURL options:nil error:&error]) {
    NSLog(@"%@", error.description);
    NSLog(@"%@", error.debugDescription);
    abort();
  } // if
  
  return _coordinator;
}

- (NSManagedObjectContext*)managedObjectContext {
  if(nil != _context) {
    return _context;
  } // if
  
  if(nil == _coordinator) {
    [self persistentStoreCoordinator];
  } // if
  
  _context =[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
  [_context setPersistentStoreCoordinator:_coordinator];
  return _context;
}

#pragma mark - Core Data Stack


- (NSArray*)getContentBaseByArchivePath:(NSString*)archivePath {
  
  NSEntityDescription* desc =nil;
  desc =[NSEntityDescription entityForName:@"ContentBase" inManagedObjectContext:self.managedObjectContext];
  
  NSFetchRequest* req =nil;
  req =[[NSFetchRequest alloc] init];
  
  NSPredicate* predicate =[NSPredicate predicateWithFormat:@"archivePath == %@", archivePath];

  [req setEntity:desc];
  [req setPredicate:predicate];
  
  NSError* err =nil;
  NSArray* result =nil;
  result =[self.managedObjectContext executeFetchRequest:req error:&err];
  if(nil != err) {
    NSLog(@"%@", err.debugDescription);
    return nil;
  } // if
  
  return result;
}

- (NSArray*)getAllContentBase {
  
  NSEntityDescription* desc =nil;
  desc =[NSEntityDescription entityForName:@"ContentBase" inManagedObjectContext:self.managedObjectContext];
  
  NSFetchRequest* req =nil;
  req =[[NSFetchRequest alloc] init];
  
  // NSPredicate* predicate =[NSPredicate predicateWithFormat:@"loginDateTime != nil"];
  
  // SQLite一定要加排序，否則資料query出來順序每次都會不一樣
  NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"archivePath" ascending:YES];
  [req setSortDescriptors:[NSArray arrayWithObject:sortByName]];
  
  [req setEntity:desc];
  // [req setPredicate:predicate];
  
  NSError* err =nil;
  NSArray* result =nil;
  result =[self.managedObjectContext executeFetchRequest:req error:&err];
  if(nil != err) {
    NSLog(@"%@", err.debugDescription);
    return nil;
  } // if
  
  return result;
}

- (void)writeContentBase:(NSString*)_archivePath previewPictureData:(NSData*)data {
  ContentBase* contentBase =nil;
  contentBase =[NSEntityDescription insertNewObjectForEntityForName:@"ContentBase"
                                             inManagedObjectContext:self.managedObjectContext];
  
  contentBase.archivePath =_archivePath;        // 內容壓縮檔路徑
  contentBase.previewPictureData =[data copy];  // 預覽圖內容，用binary存到table中
  contentBase.downloadComplete =[NSNumber numberWithBool:NO];
  
  NSError* err;
  [self.managedObjectContext save:&err];
  if(nil != err) {
    NSLog(@"%@", err.debugDescription);
  } // if
}


#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  if([response respondsToSelector:@selector(statusCode)]){
    NSInteger statusCode = [((NSHTTPURLResponse *)response) statusCode];
    if(200 != statusCode) {
      NSLog(@"發生錯誤:HTTP Error:%d", (int)statusCode);
      return;
    } // if
    
    buffer =[[NSMutableData alloc] init];
    expectedContentLength =response.expectedContentLength;
    receivedLength =0;
  } // if
  
  if(YES == [self.requestTracking respondsToSelector:@selector(begin:)]) {
    [self.requestTracking begin:self.currentBase];
  } // if
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [buffer appendData:data];
  receivedLength +=[data length];
  
  if(YES == [self.requestTracking respondsToSelector:@selector(update:updateProgress:)]) {
    double progressValue =0.0;
    if(0 != expectedContentLength) {
      progressValue = receivedLength / expectedContentLength;
    } // if
    [self.requestTracking update:self.currentBase updateProgress:progressValue];
  } // if
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  // 1.組合本地端的存檔檔名
  NSString* fileName =[self.currentBase.archivePath lastPathComponent];
  NSURL* storeURL =[[Directories.instance cacheDirectory] URLByAppendingPathComponent:fileName];
  
  // 2.如果buffer裡有東西，就寫到disk中去
  if(nil != buffer && 0 < [buffer length]) {
    NSString* storePath =[storeURL path];
    if(YES != [buffer writeToFile:storePath atomically:YES]) {
      NSLog(@"寫入%@失敗", storePath);
      return;
    } // if
    
    buffer =nil;  // 把buffer標記成可以清掉的變數
    
    // 寫入成功，開始解壓縮
    ZipArchive* zipFile =nil;
    zipFile =[[ZipArchive alloc] init];
    // zipFile.delegate =self;
    
    // 移掉附檔名後組合出一個新的路徑當作解壓縮的目錄，不移掉附檔名的話會出問題
    NSURL* unzipURL =[[Directories.instance cacheDirectory] URLByAppendingPathComponent:[fileName stringByDeletingPathExtension]];
    
    [zipFile UnzipOpenFile:storePath];
    [zipFile UnzipFileTo:[unzipURL path] overWrite:YES];
    [zipFile UnzipCloseFile];
    
    zipFile =nil;
    
    // 把壓縮檔砍掉
    NSError* error;
    NSFileManager* fileManager =[NSFileManager defaultManager];
    [fileManager removeItemAtPath:storePath error:&error];
    if(nil != error) {
      NSLog(@"%@", error.debugDescription);
    } // if
    
    // 解壓縮完畢之後，並把ContentItem加到ContentBase裡面
    NSString* unzipUrlPath =[unzipURL path];
    // NSFileManager *localFileManager=[[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:unzipUrlPath];
    
    NSString* file;
    NSString* fullFilePath;
    ContentItem* contentItem =nil;
    
    bool processResult =YES;
    while ((file = [dirEnum nextObject])) {
      if([[file pathExtension] isEqualToString: @"jpg"]) {
        fullFilePath =[unzipUrlPath stringByAppendingPathComponent:file];
        
        contentItem =[NSEntityDescription insertNewObjectForEntityForName:@"ContentItem"
                                          inManagedObjectContext:self.managedObjectContext];
        
        NSData* data =nil;
        UIImage* img =[UIImage imageWithContentsOfFile:fullFilePath];
        data =UIImageJPEGRepresentation(img, 0.5);
        contentItem.pictureData =data; // [data copy];
        
        // 建立預覽用的小圖
        double ratio =img.size.height / img.size.width;
        CGSize size =CGSizeMake(164, 164 *ratio);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage* thumbnailImg =UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        data =UIImageJPEGRepresentation(thumbnailImg, 0.5);
        contentItem.thumbnailData =data; // [data copy];
        img =nil;
        thumbnailImg =nil;
        
        contentItem.type =[NSNumber numberWithInt:kItemTypeJPG];
        contentItem.path =[unzipUrlPath stringByAppendingPathComponent:file];
        contentItem.base = self.currentBase;
        
        // [self.currentBase addItemsObject:contentItem];
        self.currentBase.type =[NSNumber numberWithInt:kItemTypeJPG];
        data =nil;
        
        processResult =YES;
      } // if
      
      else if([[file pathExtension] isEqualToString: @"png"]) {
        fullFilePath =[unzipUrlPath stringByAppendingPathComponent:file];
        
        contentItem =[NSEntityDescription insertNewObjectForEntityForName:@"ContentItem"
                                                   inManagedObjectContext:self.managedObjectContext];
        
        NSData* data =nil;
        UIImage* img =[UIImage imageWithContentsOfFile:fullFilePath];
        data =UIImagePNGRepresentation(img);
        contentItem.pictureData =data; // [data copy];
        
        // 建立預覽用的小圖
        double ratio =img.size.height / img.size.width;
        CGSize size =CGSizeMake(164, 164 *ratio);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage* thumbnailImg =UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        data =UIImagePNGRepresentation(thumbnailImg);
        contentItem.thumbnailData =data; // [data copy];
        img =nil;
        thumbnailImg =nil;

        contentItem.type =[NSNumber numberWithInt:kItemTypePNG];
        contentItem.path =[unzipUrlPath stringByAppendingPathComponent:file];
        contentItem.base = self.currentBase;
        
        // [self.currentBase addItemsObject:contentItem];
        self.currentBase.type =[NSNumber numberWithInt:kItemTypePNG];
        data =nil;
        
        processResult =YES;
      } // else if
      
      else if([[file pathExtension] isEqualToString: @"mp4"]) {
        fullFilePath =[unzipUrlPath stringByAppendingPathComponent:file];
        contentItem =[NSEntityDescription insertNewObjectForEntityForName:@"ContentItem"
                                                   inManagedObjectContext:self.managedObjectContext];
        
        contentItem.type =[NSNumber numberWithInt:kItemTypeMP4];
        contentItem.path =[unzipUrlPath stringByAppendingPathComponent:file];
        contentItem.base = self.currentBase;
        
        // [self.currentBase addItemsObject:contentItem];
        self.currentBase.type =[NSNumber numberWithInt:kItemTypeMP4];
        
        processResult =YES;
        break; // mp4只能有一個檔案，加進去之後就脫離迴圈
      } // else if
      
      else {
        self.currentBase.type =[NSNumber numberWithInt:kItemTypeUnknown];
        processResult =NO;
        NSLog(@"無法辨識的檔案%@", file);
      } // else
    } // while
    
    [fileManager removeItemAtPath:unzipUrlPath error:&error];
    if(nil != error) {
      NSLog(@"%@", error.debugDescription);
    } // if
    
    if(YES != processResult) {
      self.currentBase.downloadComplete =[NSNumber numberWithBool:YES];
      NSError* err;
      [self.managedObjectContext save:&err];
      if(nil != err) {
        NSLog(@"%@", err.debugDescription);
      } // if
      
      [self.managedObjectContext refreshObject:self.currentBase mergeChanges:NO];
      if(nil != err) {
        NSLog(@"%@", err.debugDescription);
      } // if
    }
    
    if(YES == processResult) {
      if(YES == [self.requestTracking respondsToSelector:@selector(complete:)]) {
        [self.requestTracking complete:self.currentBase];
      } // if
    } // if
    else {
      if(YES == [self.requestTracking respondsToSelector:@selector(fail:message:)]) {
        [self.requestTracking fail:self.currentBase message:@"下載內容終有無法辨識的內容"];
      } // if
    } // else
  } // if
  
  else {
    if(YES == [self.requestTracking respondsToSelector:@selector(fail:message:)]) {
      [self.requestTracking fail:self.currentBase message:@"處理內容發生問題"];
    } // if
  } // else
}


#pragma mark -
- (id)init {
  self =[super init];
  if(self) {
    _queue =[[NSOperationQueue alloc] init];
    [self.queue setMaxConcurrentOperationCount:1];
  } // if
  
  return self;
}

- (void)requestBase:(ContentBase*)base {
  DownloadTask* task =nil;
  task =[[DownloadTask alloc] init];
  task.manager =self;
  task.contentBase =base;
  
  [self.queue addOperation:task];
}

- (NSMutableArray*)loadList:(NSString*)urlPath {
  NSMutableArray* list =nil;
  list =[[NSMutableArray alloc] init];
  
  @try {
    NSData* data =nil;
    data =[self loadItem:urlPath paramName:@"Address" paramValue:@"aaa"];
    if(nil == data) {
      return list;
    } // if
    
    // NSString* urlContent =[NSString alloc];
    // urlContent =[urlContent initWithData:data encoding:NSASCIIStringEncoding];
    
    NSError* error;
    list =[NSJSONSerialization JSONObjectWithData:data
                               options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers
                               error:&error];
    
    data =nil;
    if(nil != error) {
      NSLog(@"%@", error.debugDescription);
    } // if
  } // @try
  @catch(NSException* ex) {
    NSLog(@"%@", ex.debugDescription);
  } // @catch
  
  return list;
}




// 預覽圖下載
- (void)loadPreviewItem:(NSString*)_archivePath previewPath:(NSString*)_previewPath {

  NSArray* results =[self getContentBaseByArchivePath:_archivePath];
  if(nil != results && 0 < results.count) {
    NSLog(@"已有資料：%@", _archivePath);
    return;
  } // if
    
  NSData* data =nil;
  data =[self loadItem:_previewPath paramName:nil paramValue:nil];
    
  // NSString* fileName =[_previewPath lastPathComponent];
  // NSURL* storeURL =[[Directories.instance documentDirectory] URLByAppendingPathComponent:fileName];
  if(nil == data) {
    NSLog(@"下載無資料");
    return;
  } // if
  
  /*
  NSString* writePath =[storeURL path];
  if(YES != [data writeToFile:writePath atomically:YES]) {
    NSLog(@"無法寫入%@", writePath);
    return;
  } // if
  */
  
  [self writeContentBase:_archivePath previewPictureData:data];
}

-(void) ErrorMessage:(NSString*) msg {
  NSLog(@"Error : %@", msg);
}

@end
