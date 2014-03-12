//
//  com_symAppDelegate.h
//  SYM
//
//  Created by HsiuYi on 13/9/17.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "ContentManager.h"
#import "UserData.h"

@interface com_symAppDelegate : UIResponder <UIApplicationDelegate> {
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString* currentUser;
// @property (strong, nonatomic) ContentManager* contentManager;

@end
