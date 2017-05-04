//
//  FMPlayerViewController.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/3/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "FMPlayerViewController.h"
#import <MarqueeLabel/MarqueeLabel.h>
#import <FeedMedia/FeedMedia.h>
#import <FeedMedia/FeedMediaUI.h>

#define CALL_TO_ACTION @"Press play to start!"

@interface FMPlayerViewController ()

@property (strong, nonatomic) IBOutlet MarqueeLabel *noticeLabel;
@property (strong, nonatomic) IBOutlet FMMetadataLabel *trackLineOneLabel;
@property (strong, nonatomic) IBOutlet FMMetadataLabel *trackLineTwoLabel;

@end

@implementation FMPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _noticeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _trackLineTwoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _trackLineOneLabel.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];

    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateUpdated:) name:FMAudioPlayerPlaybackStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skipFailed:) name:FMAudioPlayerSkipFailedNotification object:player];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Metadata display

- (void) skipFailed: (NSNotification *) notification {
    [self updateMetadataDisplay];
}

- (void) stateUpdated: (NSNotification *) notification {
    [self updateMetadataDisplay];
}

- (void) updateMetadataDisplay {
    FMAudioPlayerPlaybackState state = [FMAudioPlayer sharedPlayer].playbackState;
    
    switch (state) {
        case FMAudioPlayerPlaybackStatePaused:
        case FMAudioPlayerPlaybackStatePlaying:
        case FMAudioPlayerPlaybackStateStalled:
        case FMAudioPlayerPlaybackStateRequestingSkip:
            // show track info
            _trackLineOneLabel.hidden = NO;
            _trackLineTwoLabel.hidden = NO;
            _noticeLabel.hidden = YES;
            break;
            
        case FMAudioPlayerPlaybackStateComplete:
        case FMAudioPlayerPlaybackStateReadyToPlay:
            // show call to action
            _trackLineOneLabel.hidden = YES;
            _trackLineTwoLabel.hidden = YES;
            
            _noticeLabel.text = CALL_TO_ACTION;
            _noticeLabel.hidden = NO;
            break;
            
        case FMAudioPlayerPlaybackStateUnavailable:
        case FMAudioPlayerPlaybackStateUninitialized:
        case FMAudioPlayerPlaybackStateWaitingForItem:
            // show nothing!
            _trackLineOneLabel.hidden = YES;
            _trackLineTwoLabel.hidden = YES;
            _noticeLabel.hidden = YES;
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
