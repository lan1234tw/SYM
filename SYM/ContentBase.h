//
//  ContentBase.h
//  SYM
//
//  Created by HsiuYi on 2014/1/27.
//  Copyright (c) 2014年 HsiuYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContentItem;

@interface ContentBase : NSManagedObject

@property (nonatomic, retain) NSString * archivePath;
@property (nonatomic, retain) NSNumber * downloadComplete;
@property (nonatomic, retain) NSString * endDate;
@property (nonatomic, retain) NSString * startDate;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSData * previewPictureData;
@property (nonatomic, retain) NSOrderedSet *items;
@end

@interface ContentBase (CoreDataGeneratedAccessors)

- (void)insertObject:(ContentItem *)value inItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromItemsAtIndex:(NSUInteger)idx;
- (void)insertItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInItemsAtIndex:(NSUInteger)idx withObject:(ContentItem *)value;
- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)values;
- (void)addItemsObject:(ContentItem *)value;
- (void)removeItemsObject:(ContentItem *)value;
- (void)addItems:(NSOrderedSet *)values;
- (void)removeItems:(NSOrderedSet *)values;
@end
