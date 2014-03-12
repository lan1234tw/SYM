//
//  ContentManager.h
//  SYM
//
//  Created by HsiuYi on 2013/11/20.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentBase.h"
#import "ContentItem.h"
#import "ZipArchive.h"

// 追蹤下載過程的protocol，加入NSObject之後才能使用respondsToSelector來檢查是否有實作optional的method
@protocol ContentRequestTracking<NSObject>
@required
- (void)begin:(ContentBase*)base;
- (void)update:(ContentBase*)base updateProgress:(double)g;
- (void)complete:(ContentBase*)base;
- (void)fail:(ContentBase*)base message:(NSString*)msg;
@end


@interface ContentManager : NSObject<ZipArchiveDelegate, NSURLConnectionDataDelegate> {
  enum kItemType {
    kItemTypeJPG =10,
    kItemTypePNG =20,
    kItemTypeMP4 =30,
    kItemTypeUnknown =99,
  };
}

@property (nonatomic, weak) id<ContentRequestTracking> requestTracking;
@property (nonatomic, strong) NSOperationQueue* queue;
@property (nonatomic, weak) ContentBase* currentBase;

+ (ContentManager*)instance;

/*
- (NSManagedObjectModel*)managedObjectModel;
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator;
*/

- (NSManagedObjectContext*)managedObjectContext;

- (NSArray*)getAllContentBase;
- (NSArray*)getContentBaseByArchivePath:(NSString*)archivePath;

- (NSMutableArray*)loadList:(NSString*)urlPath;
- (void)loadPreviewItem:(NSString*)_archivePath previewPath:(NSString*)_previewPath;
- (void)requestBase:(ContentBase*)base;
- (void)ErrorMessage:(NSString*) msg;

@end
