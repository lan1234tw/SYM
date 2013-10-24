//
//  com_symAppDelegate.m
//  SYM
//
//  Created by HsiuYi on 13/9/17.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "com_symAppDelegate.h"



@implementation com_symAppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Override point for customization after application launch.
  return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (NSURL*)applicationDocumentDirectory {
    return [[[NSFileManager defaultManager]
              URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma marks - Core Data
- (NSManagedObjectModel*)managedObjectModel {
    if(nil != _objectModel) {
        return _objectModel;
    } // if
    
    NSURL* modelURL =[[NSBundle mainBundle] URLForResource:@"ContentModel" withExtension:@"momd"];
    _objectModel =[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _objectModel;
}

- (NSPersistentStoreCoordinator*)persistentStoreCoordinator {
    if(nil != _coordinator) {
        return _coordinator;
    } // if
    
    NSURL* storeURL =[[self applicationDocumentDirectory] URLByAppendingPathComponent:@"ContentModel.sqlite"];
    NSError* error =nil;
    _coordinator =[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    if(nil == [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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
  
    _context =[[NSManagedObjectContext alloc] init];
    [_context setPersistentStoreCoordinator:_coordinator];
    return _context;
}

@end
