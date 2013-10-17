//
//  ContentBase.h
//  SYM
//
//  Created by HsiuYi on 13/10/15.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ContentBase : NSManagedObject

@property (nonatomic, retain) NSString * endDate;
@property (nonatomic, retain) NSString * pathBase;
@property (nonatomic, retain) NSString * startDate;
@property (nonatomic, retain) NSOrderedSet *items;
@end

@interface ContentBase (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inItemsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromItemsAtIndex:(NSUInteger)idx;
- (void)insertItems:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeItemsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInItemsAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)values;
- (void)addItemsObject:(NSManagedObject *)value;
- (void)removeItemsObject:(NSManagedObject *)value;
- (void)addItems:(NSOrderedSet *)values;
- (void)removeItems:(NSOrderedSet *)values;
@end
