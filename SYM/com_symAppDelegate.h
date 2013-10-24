//
//  com_symAppDelegate.h
//  SYM
//
//  Created by HsiuYi on 13/9/17.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface com_symAppDelegate : UIResponder <UIApplicationDelegate> {
    NSManagedObjectContext* _context;
    NSManagedObjectModel* _objectModel;
    NSPersistentStoreCoordinator* _coordinator;
}

@property (strong, nonatomic) UIWindow *window;

- (NSManagedObjectModel*)managedObjectModel;
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator;
- (NSManagedObjectContext*)managedObjectContext;

@end
