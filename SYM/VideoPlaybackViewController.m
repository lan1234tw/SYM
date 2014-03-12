//
//  VideoPlaybackViewController.m
//  SYM
//
//  Created by HsiuYi on 13/10/1.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "VideoPlaybackViewController.h"


@interface VideoPlaybackViewController ()

- (void)startPlayVideo:(id)paramSender;
- (void)stopPlayVideo:(id)paramSender;
- (void)videoHasFinishedPlaying:(NSNotification*)paramNotification;

@end

@implementation VideoPlaybackViewController
@synthesize moviePlayer = _moviePlayer;

- (void)startPlayVideo:(id)paramSender {
    NSURL* url =[NSURL fileURLWithPath:self.videoPath];
    
    if(nil != self.moviePlayer) {
        [self stopPlayVideo:nil];
    } // if
    
    self.moviePlayer =[[MPMoviePlayerController alloc] initWithContentURL:url];
    
    if(nil != self.moviePlayer) {
        CGRect r =CGRectInset(self.view.bounds, 20, 20);
        [self.moviePlayer.view setFrame:r];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(videoPlayerPlaybackStateChanged:)
         name:MPMoviePlayerPlaybackStateDidChangeNotification
         object:self.moviePlayer];
        
        self.moviePlayer.scalingMode =MPMovieScalingModeAspectFit;
        self.moviePlayer.controlStyle =MPMovieControlStyleEmbedded;
        [self.moviePlayer play];    // 開始播放
        [self.view addSubview:self.moviePlayer.view];
        // [self.moviePlayer setFullscreen:YES animated:YES];
    } // if
    else {
        NSLog(@"無法初始化影片播放器");
    } // else
}

- (void)stopPlayVideo:(id)paramSender {
    if(nil != self.moviePlayer) {
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:MPMoviePlayerPlaybackStateDidChangeNotification
         object:self.moviePlayer];
        
        [self.moviePlayer stop];
        
        if([self.moviePlayer.view.superview isEqual:self.view]) {
            [self.moviePlayer.view removeFromSuperview];
        } // if
    } // if
}

- (void)videoHasFinishedPlaying:(NSNotification*)paramNotification {
    NSNumber* reason =[paramNotification.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    if(nil != reason) {
        NSInteger reasonAsInteger =[reason integerValue];
        switch(reasonAsInteger) {
            case MPMovieFinishReasonPlaybackEnded: {
                break;
            } // case
                
            case MPMovieFinishReasonPlaybackError: {
                break;
            } // case
                
            case MPMovieFinishReasonUserExited: {
                break;
            } // case
        } // switch
        
        [self stopPlayVideo:nil];
    } // if
}


- (void) videoPlayerPlaybackStateChanged:(NSNotification*) aNotification {
  MPMoviePlayerController *player = [aNotification object];
  
  if(player.playbackState == MPMoviePlaybackStatePaused){
    [self.navigationController.navigationBar setTranslucent:YES];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    self.navigationController.navigationBarHidden = NO;
  }
  else if(player.playbackState == MPMoviePlaybackStatePlaying) {
    self.navigationController.navigationBarHidden = YES;
  }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
  [self startPlayVideo:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  self.navigationController.navigationBarHidden =YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
