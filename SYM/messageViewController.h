//
//  messageViewController.h
//  SYM
//
//  Created by HsiuYi on 13/10/1.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface messageViewController : UIViewController

@property (nonatomic, strong) MPMoviePlayerController* moviePlayer;

- (IBAction)play_touched:(id)sender;

@end
