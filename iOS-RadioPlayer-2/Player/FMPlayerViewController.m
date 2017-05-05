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
@property (strong, nonatomic) IBOutlet UIScrollView *stationScroller;
@property (strong, nonatomic) IBOutlet UIView *stationScrollerContent;

@end

@implementation FMPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _noticeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _trackLineTwoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _trackLineOneLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // populate the station scroller
    [self populateStationScroller];
}

- (void) populateStationScroller {
    NSArray *stations = [FMAudioPlayer sharedPlayer].stationList;
    NSArray *colors = @[ [UIColor greenColor], [UIColor orangeColor], [UIColor purpleColor] ];
    
    // add a page for each station
    UIView *previousStation = nil;
    for (int i = 0; i < stations.count; i++) {
        NSLog(@"adding station");
        
        FMStation *station = [stations objectAtIndex:i];
        
        UIView *stationView = [[UIView alloc] init];
        stationView.backgroundColor = [colors objectAtIndex:i];

        UILabel *stationTitle = [[UILabel alloc] init];
        stationTitle.text = station.name;
        
        [stationView addSubview:stationTitle];

        // title in center of view
        stationTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [stationView addConstraint:[NSLayoutConstraint constraintWithItem:stationTitle attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:stationView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [stationView addConstraint:[NSLayoutConstraint constraintWithItem:stationTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:stationView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];

        // stick view in content view
        [_stationScrollerContent addSubview:stationView];
        
        // station view sizing:

        stationView.translatesAutoresizingMaskIntoConstraints = NO;

        // top = content view
        [_stationScrollerContent addConstraint:[NSLayoutConstraint constraintWithItem:stationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_stationScrollerContent attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        // bottom = content view
        [_stationScrollerContent addConstraint:[NSLayoutConstraint constraintWithItem:stationView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_stationScrollerContent attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        // width = screen width
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:stationView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        // left = right of previous station or anchored to left side of content view
        if (previousStation == nil) {
            [_stationScrollerContent addConstraint:[NSLayoutConstraint constraintWithItem:stationView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_stationScrollerContent attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        } else {
            [_stationScrollerContent addConstraint:[NSLayoutConstraint constraintWithItem:stationView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:previousStation attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        }
        
        previousStation = stationView;
    }
    
    // finally, the container is the width of all the stations together
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_stationScrollerContent attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:stations.count constant:0]];

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
