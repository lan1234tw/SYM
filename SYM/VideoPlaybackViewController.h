//
//  VideoPlaybackViewController.h
//  SYM
//
//  Created by HsiuYi on 13/10/1.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VideoPlaybackViewController : UIViewController

@property (nonatomic, strong) MPMoviePlayerController* moviePlayer;
@property (nonatomic, strong) NSString* videoPath;

@end
