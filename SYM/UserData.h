//
//  UserData.h
//  SYM
//
//  Created by HsiuYi on 2013/11/12.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserData : NSManagedObject

@property (nonatomic, retain) NSDate * loginDateTime;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * userID;

@end
