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
  NSManagedObjectModel* _objectModel;
  NSPersistentStoreCoordinator* _coordinator;
  
  NSMutableData* buffer;
  long long expectedContentLength; // 檔案長度
  long long receivedLength; // 已接收到的資料長度
}

@end

@implementation ContentManager
@synthesize requestTracking = _requestTracking, queue = _queue, context =_context, importContext = _importContext;

static NSString* sourceFilename =@"ContentModel.sqlite";

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
  NSString *postLength = [NSString stringWithFormat:@"%ul", [postData length]];
  
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

#pragma mark - Core Data Stack
- (NSManagedObjectModel*)objectModel {
  return _objectModel;
}

- (NSArray*)getContentBaseByArchivePath:(NSString*)archivePath {
  
  NSEntityDescription* desc =nil;
  desc =[NSEntityDescription entityForName:@"ContentBase" inManagedObjectContext:self.context];
  
  NSFetchRequest* req =nil;
  req =[[NSFetchRequest alloc] init];
  
  NSPredicate* predicate =[NSPredicate predicateWithFormat:@"archivePath == %@", archivePath];

  [req setEntity:desc];
  [req setPredicate:predicate];
  
  NSError* err =nil;
  NSArray* result =nil;
  result =[self.context executeFetchRequest:req error:&err];
  if(nil != err) {
    NSLog(@"%@", err.debugDescription);
    return nil;
  } // if
  
  return result;
}

- (NSArray*)getAllContentBase {
  
  NSEntityDescription* desc =nil;
  desc =[NSEntityDescription entityForName:@"ContentBase" inManagedObjectContext:self.context];
  
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
  result =[self.context executeFetchRequest:req error:&err];
  if(nil != err) {
    NSLog(@"%@", err.debugDescription);
    return nil;
  } // if
  
  return result;
}

- (void)writeContentBase:(NSString*)_archivePath previewPictureData:(NSData*)data {
  [self.importContext performBlockAndWait:^{
    ContentBase* contentBase =nil;
    contentBase =[NSEntityDescription insertNewObjectForEntityForName:@"ContentBase"
                                               inManagedObjectContext:self.importContext];
    
    contentBase.archivePath =_archivePath;        // 內容壓縮檔路徑
    contentBase.previewPictureData =[data copy];  // 預覽圖內容，用binary存到table中
    contentBase.downloadComplete =[NSNumber numberWithBool:NO];
    
    [self saveContext];
  }];
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
    NSURL* unzipURL =[[Directories.instance cacheDirectory]
                      URLByAppendingPathComponent:[fileName stringByDeletingPathExtension]];
    
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
    NSDirectoryEnumerator *dirEnum = [fileManager enumeratorAtPath:unzipUrlPath];
    
    NSString* file;
    NSString* fullFilePath;
    ContentItem* contentItem =nil;
    
    bool processResult =YES;
    while ((file = [dirEnum nextObject])) {
      @autoreleasepool {
      
        if([file.pathExtension isEqualToString:@"jpg"]) {
        fullFilePath =[unzipUrlPath stringByAppendingPathComponent:file];
        
        /* 這邊必須寫context而非importContext的原因在於：
           ContentBase已經被讀到main queue那個context去了，如果沿用importContext的話，
           會發生無法跨越context建立relationship的exception。
         */
        contentItem =[NSEntityDescription insertNewObjectForEntityForName:@"ContentItem"
                                          inManagedObjectContext:self.context];
        
        NSData* data =nil;
        UIImage* img =[UIImage imageWithContentsOfFile:fullFilePath];
        data =UIImageJPEGRepresentation(img, 0.5);
        contentItem.pictureData =data;
        
        // 建立預覽用的小圖
        double ratio =img.size.height / img.size.width;
        CGSize size =CGSizeMake(164, 164 *ratio);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage* thumbnailImg =UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        data =UIImageJPEGRepresentation(thumbnailImg, 0.5);
        contentItem.thumbnailData =data;
        img =nil;
        thumbnailImg =nil;
        
        contentItem.type =[NSNumber numberWithInt:kItemTypeJPG];
        contentItem.path =[unzipUrlPath stringByAppendingPathComponent:file];
        contentItem.base = self.currentBase;

        self.currentBase.type =[NSNumber numberWithInt:kItemTypeJPG];
        data =nil;
        
        processResult =YES;
      } // if
      
      else if([file.pathExtension isEqualToString:@"png"]) {
        fullFilePath =[unzipUrlPath stringByAppendingPathComponent:file];
        
        contentItem =[NSEntityDescription insertNewObjectForEntityForName:@"ContentItem"
                                                   inManagedObjectContext:self.importContext];
        
        NSData* data =nil;
        UIImage* img =[UIImage imageWithContentsOfFile:fullFilePath];
        data =UIImagePNGRepresentation(img);
        contentItem.pictureData =data;
        
        // 建立預覽用的小圖
        double ratio =img.size.height / img.size.width;
        CGSize size =CGSizeMake(164, 164 *ratio);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage* thumbnailImg =UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        data =UIImagePNGRepresentation(thumbnailImg);
        contentItem.thumbnailData =data;
        img =nil;
        thumbnailImg =nil;

        contentItem.type =[NSNumber numberWithInt:kItemTypePNG];
        contentItem.path =[unzipUrlPath stringByAppendingPathComponent:file];
        contentItem.base = self.currentBase;

        self.currentBase.type =[NSNumber numberWithInt:kItemTypePNG];
        data =nil;
        
        processResult =YES;
      } // else if
      
        else if([file.pathExtension isEqualToString:@"mp4"]) {
        fullFilePath =[unzipUrlPath stringByAppendingPathComponent:file];
        contentItem =[NSEntityDescription insertNewObjectForEntityForName:@"ContentItem"
                                          inManagedObjectContext:self.importContext];
        
        contentItem.type =[NSNumber numberWithInt:kItemTypeMP4];
        contentItem.path =[unzipUrlPath stringByAppendingPathComponent:file];
        contentItem.base = self.currentBase;

        self.currentBase.type =[NSNumber numberWithInt:kItemTypeMP4];
        
        processResult =YES;
        break; // mp4只能有一個檔案，加進去之後就脫離迴圈
      } // else if
      
        else {
        self.currentBase.type =[NSNumber numberWithInt:kItemTypeUnknown];
        processResult =NO;
        NSLog(@"無法辨識的檔案%@", file);
      } // else
        
      } // @autoreleasepool
    } // while
    
    [fileManager removeItemAtPath:unzipUrlPath error:&error];
    if(nil != error) {
      NSLog(@"%@", error.debugDescription);
    } // if
    
    if(YES != processResult) {
      self.currentBase.downloadComplete =[NSNumber numberWithBool:YES];
      NSError* err;
      [self saveContext];
      
      [self.importContext refreshObject:self.currentBase mergeChanges:NO];
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
        [self.requestTracking fail:self.currentBase message:@"下載內容中有無法辨識的內容"];
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
    
    // === Start to create CoreData Stack
    NSError* error =nil;
    
    // === Managed object model
    _objectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    
    // === Persistent store coordinator
    NSURL* storeURL =[Directories.instance.documentDirectory
                      URLByAppendingPathComponent:sourceFilename];
    
    _coordinator =[[NSPersistentStoreCoordinator alloc]
                   initWithManagedObjectModel:_objectModel];
    
    if(nil == [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
                            configuration:nil
                            URL:storeURL
                            options:nil
                            error:&error]) {
      NSLog(@"%@", error.description);
      NSLog(@"%@", error.debugDescription);
    } // if
    
    // === Managed object context
    // 先設定背景作業的context
    _importContext =[[NSManagedObjectContext alloc]
               initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_importContext setPersistentStoreCoordinator:_coordinator];
    [_importContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    // 再設定UI所使用的context
    _context =[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_context setParentContext:_importContext];
    [_context setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
  } // if
  
  return self;
}



#pragma mark - SAVING
- (BOOL)saveContext {
  if(YES == [_context hasChanges]) {
    NSError *error = nil;
    if ([_context save:&error]) {
      NSLog(@"_context SAVED changes to persistent store");
      return YES;
    } // if
    else {
      NSLog(@"Failed to save _context: %@", error);
      return NO;
    } // else
  } // if
  
  return YES;
}


- (void)backgroundSaveContext {
  [self saveContext]; // 先把前景的context存起來
  
  // Then, save the parent context.
  [_importContext performBlock:^{
    if(YES == [_importContext hasChanges]) {
      NSError *error = nil;
      if ([_importContext save:&error]) {
        NSLog(@"_backgroundContext SAVED changes to persistent store");
      } // if
      else {
        NSLog(@"_backgroundContext FAILED to save: %@", error);
      } // else
    } // if
    else {
      NSLog(@"_parentContext SKIPPED saving as there are no changes");
    } // else
  }];
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
