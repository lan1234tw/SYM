//
//  messageViewController.m
//  SYM
//
//  Created by HsiuYi on 13/10/1.
//  Copyright (c) 2013年 HsiuYi. All rights reserved.
//

#import "messageViewController.h"


@interface messageViewController ()

- (void)startPlayVideo:(id)paramSender;
- (void)stopPlayVideo:(id)paramSender;
- (void)videoHasFinishedPlaying:(NSNotification*)paramNotification;

@end

@implementation messageViewController
@synthesize moviePlayer = _moviePlayer;

- (void)startPlayVideo:(id)paramSender {
    @try {
    NSBundle* mainBundle =[NSBundle mainBundle];
    
    NSString* urlAsString =[mainBundle pathForResource:@"test" ofType:@"mp4"];
    
    NSURL* url =[NSURL fileURLWithPath:urlAsString];
    
    if(nil != self.moviePlayer) {
        [self stopPlayVideo:nil];
    } // if
    
    self.moviePlayer =[[MPMoviePlayerController alloc] initWithContentURL:url];
    
    if(nil != self.moviePlayer) {
        CGRect r =CGRectInset(self.view.bounds, 20, 20);
        [self.moviePlayer.view setFrame:r];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(videoHasFinishedPlaying:)
         name:MPMoviePlayerPlaybackDidFinishNotification
         object:self.moviePlayer];
        
        self.moviePlayer.scalingMode =MPMovieScalingModeAspectFit;
        [self.moviePlayer play];    // 開始播放
        [self.view addSubview:self.moviePlayer.view];
        // [self.moviePlayer setFullscreen:YES animated:YES];
    } // if
    else {
        NSLog(@"無法初始化影片播放器");
    } // else
    } // @try
    @catch (NSException* ex) {
        NSLog(@"%@", ex.debugDescription);
    }
}

- (void)stopPlayVideo:(id)paramSender {
    if(nil != self.moviePlayer) {
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:MPMoviePlayerPlaybackDidFinishNotification
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
                NSLog(@"error >>>>>>>>");
                break;
            } // case
                
            case MPMovieFinishReasonUserExited: {
                break;
            } // case
        } // switch
        
        [self stopPlayVideo:nil];
    } // if
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)play_touched:(id)sender {
    [self startPlayVideo:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    CGRect r =CGRectInset(self.view.bounds, 20, 20);
    
    CGRect o =self.view.bounds;
    NSLog(@"%f %f %f %f", o.origin.x, o.origin.y, o.size.height, o.size.width);
    NSLog(@"%f %f %f %f", r.origin.x, r.origin.y, r.size.height, r.size.width);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
