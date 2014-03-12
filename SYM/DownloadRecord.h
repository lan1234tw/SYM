//
//  DownloadRecord.h
//  SYM
//
//  Created by HsiuYi on 2013/11/12.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContentBase;

@interface DownloadRecord : NSManagedObject

@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSSet *contents;
@end

@interface DownloadRecord (CoreDataGeneratedAccessors)

- (void)addContentsObject:(ContentBase *)value;
- (void)removeContentsObject:(ContentBase *)value;
- (void)addContents:(NSSet *)values;
- (void)removeContents:(NSSet *)values;

@end
