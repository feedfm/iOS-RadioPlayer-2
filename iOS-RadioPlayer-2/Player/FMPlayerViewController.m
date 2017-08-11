//
//  FMPlayerViewController.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/3/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "FMPlayerViewController.h"
#import "FMStationCollectionViewController.h"
#import "FMPlaylistCollectionView.h"
#import "FMResources.h"
#import "FMPlayHistoryCollectionView.h"
#import "UIImage+FMAdjustImageAlpha.h"
#import <MarqueeLabel/MarqueeLabel.h>
#import <FeedMedia/FeedMedia.h>
#import <FeedMedia/FeedMediaUI.h>
#import <SDWebImage/UIImageView+WebCache.h>

#define CALL_TO_ACTION @"Press play to start!"

@interface FMPlayerViewController ()

@property (strong, nonatomic) NSArray *visibleStations;

@property (strong, nonatomic) IBOutlet MarqueeLabel *noticeLabel;
@property (strong, nonatomic) IBOutlet FMMetadataLabel *trackLineOneLabel;
@property (strong, nonatomic) IBOutlet FMMetadataLabel *trackLineTwoLabel;
@property (strong, nonatomic) IBOutlet FMPageableStationCollectionView *stationPager;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) IBOutlet UILabel *stationLabel;
@property (strong, nonatomic) IBOutlet UIButton *stationCollectionButton;
@property (strong, nonatomic) IBOutlet UIView *stationCollectionCircle;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;
@property (strong, nonatomic) IBOutlet UIView *shareCircle;

@property (strong, nonatomic) IBOutlet FMPlayPauseButton *playPausebutton;
@property (strong, nonatomic) IBOutlet UIButton *skipButton;
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;
@property (strong, nonatomic) IBOutlet UIView *playerControlsView;
@property (strong, nonatomic) IBOutlet UIView *playerDisplayView;
@property (strong, nonatomic) IBOutlet UIButton *playHistoryButton;

@property (strong, nonatomic) IBOutlet FMPlayHistoryCollectionView *playHistoryView;
@property (strong, nonatomic) IBOutlet FMPlaylistCollectionView *playlistView;

@end

@implementation FMPlayerViewController {
    
    NSTimer *_noticeTimer;
    NSString *_defaultNoticeText;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // tweak the button styles
    [self setupButtonStyling];
    
    _visibleStations = [FMStationCollectionViewController extractVisibleStations];

    // manage station scrolling and switching
    [self setupStationScrolling];
    
    // set initialize metadata in the player controls
    [self setupMetadata];
    
    // hide or show the station collection button
    [self setupStationCollectionButton];

    // focus on the active station by default
    if (!_initiallyVisibleStation) {
        _initiallyVisibleStation = [[FMAudioPlayer sharedPlayer] activeStation];
    }
    
    // make sure the lock screen is synced with the active station
    [self setupLockScreen];
}

/**
 * Disabled buttons have our own custom look, rather than
 * the default iOS shading.
 */

- (void) setupButtonStyling {
    [self assignImageOpacity:0.5 forButton:_leftButton andState: UIControlStateDisabled fromState: UIControlStateNormal];
    [self assignImageOpacity:0.5 forButton:_rightButton andState: UIControlStateDisabled fromState: UIControlStateNormal];
    
    for (UIButton *button in @[ _playPausebutton, _skipButton, _likeButton, _dislikeButton, _playHistoryButton]) {
        [self assignImageOpacity:0.5
                       forButton:button
                        andState:UIControlStateDisabled
                       fromState:UIControlStateNormal];
        
        [self assignImageOpacity:0.75
                       forButton:button
                        andState:UIControlStateNormal
                       fromState:UIControlStateNormal];

        [self assignImageOpacity:0.75
                       forButton:button
                        andState:UIControlStateSelected
                       fromState:UIControlStateSelected];
    }
    
    // give share button a sexy round shape
    _shareCircle.layer.cornerRadius = _shareCircle.bounds.size.width / 2.0f;
    
    // and a drop shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithOvalInRect:_shareCircle.bounds];
    _shareCircle.layer.masksToBounds = NO;
    _shareCircle.layer.shadowColor = [UIColor blackColor].CGColor;
    _shareCircle.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    _shareCircle.layer.shadowOpacity = 0.5f;
    _shareCircle.layer.shadowPath = shadowPath.CGPath;
    
    // shrink the size of the image in the button
    _shareButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _shareButton.imageEdgeInsets = UIEdgeInsetsMake(12.5, 12.5, 12.5, 12.5);
    
    
}

- (void) assignImageOpacity: (CGFloat) opacity
                  forButton: (UIButton *) button
                   andState: (UIControlState) state
                  fromState: (UIControlState) fromState
{
    UIImage *adjusted = [[button imageForState:fromState] translucentImageWithAlpha:opacity];
    [button setImage:adjusted forState:state];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    // This is needed to apply autolayout constraints to UICollectionView so that
    // it can calculate its cell sizes properly.
    [_playerDisplayView layoutIfNeeded];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // display requested station
    if (_initiallyVisibleStation) {
        [self scrollToStation:_initiallyVisibleStation];
        [self updateNavigationButtonStatesAndStationNameToStation:_initiallyVisibleStation];
        _initiallyVisibleStation = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];

    [self setupMetadataEventHandlers];

    // disable notifications when the player is open
    [FMAudioPlayer sharedPlayer].disableSongStartNotifications = YES;
    
    // hide the play history by default
    [self setupPlayHistory];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self removeMetadataEventHandlers];
    
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];

    // re-enable notifications when the player is closed
    player.disableSongStartNotifications = NO;
    
    // ...and have notification taps pull the player back up
    player.statusBarNotification.notificationTappedBlock = ^{
        [FMResources presentPlayerWithTitle:self.title];
    };

}

#pragma mark - Switch to Station List interface

- (void) setupStationCollectionButton {
    // give it a sexy round shape
    _stationCollectionCircle.layer.cornerRadius = _stationCollectionCircle.bounds.size.width / 2.0f;

    // and a drop shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithOvalInRect:_stationCollectionCircle.bounds];
    _stationCollectionCircle.layer.masksToBounds = NO;
    _stationCollectionCircle.layer.shadowColor = [UIColor blackColor].CGColor;
    _stationCollectionCircle.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    _stationCollectionCircle.layer.shadowOpacity = 0.5f;
    _stationCollectionCircle.layer.shadowPath = shadowPath.CGPath;
    
    // shrink the size of the image in the button
    _stationCollectionButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _stationCollectionButton.imageEdgeInsets = UIEdgeInsetsMake(12.5, 12.5, 12.5, 12.5);
    
    // button to view station collection only appears in special cases
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    unsigned long viewControllerCount = viewControllers.count;
    
    if (_visibleStations.count == 1) {
        // no other stations to view!
        _stationCollectionCircle.hidden = YES;
        
    } else if (viewControllerCount == 1) {
        // no parent view controller, so display the button
        _stationCollectionCircle.hidden = NO;

    } else {
        UIViewController *parent = [viewControllers objectAtIndex:(viewControllerCount - 2)];
        
        if ([parent isKindOfClass:[FMStationCollectionViewController class]]) {
            // parent is station collection view controller (which user
            // can get to via navigation controller), so hide button
            _stationCollectionCircle.hidden = YES;
            
        } else {
            // parent is not station collection view controller, so show button
            _stationCollectionCircle.hidden = NO;
        }
    }

}

- (IBAction)navigateToStationCollection:(id)sender {
    // switch to station collection view
    NSArray *viewControllers = self.navigationController.viewControllers;
    unsigned long viewControllerCount = viewControllers.count;
    
    UIStoryboard *sb = [FMResources playerStoryboard];
    
    if (viewControllerCount == 1) {
        // we're the only view controller, so create a station collection viewer and push to it
        FMStationCollectionViewController *stationCollection = [sb instantiateViewControllerWithIdentifier:@"stationCollectionViewController"];
        stationCollection.title = self.title;
        
        [self.navigationController pushViewController:stationCollection animated:YES];
        
    } else {
        UIViewController *parent = [viewControllers objectAtIndex:(viewControllerCount - 2)];
        
        if ([parent isKindOfClass:[FMStationCollectionViewController class]]) {
            // the parent view controller is a station collection, so pop() to it
            // (technically, this button should be hidden and this shouldn't happen)
            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            // else create a new station collection view controller, and push to it
            
            FMStationCollectionViewController *stationCollection = [sb instantiateViewControllerWithIdentifier:@"stationCollectionViewController"];
            stationCollection.title = self.title;
            
            [self.navigationController pushViewController:stationCollection animated:YES];
        }
        
    }
    
}

#pragma mark - Manage station scrolling

- (void) setupStationScrolling {
    // populate the station pager
    _stationPager.visibleStations = _visibleStations;

    // watch for taps on scroll buttons
    [_leftButton addTarget:self action:@selector(moveLeftOneStation:) forControlEvents:UIControlEventTouchUpInside];
    [_rightButton addTarget:self action:@selector(moveRightOneStation:) forControlEvents:UIControlEventTouchUpInside];
    
    // watch for station scroll events to update left/right button states
    _stationPager.pageableStationDelegate = self;
}

- (void) visibleStationDidChange {
    [self updateNavigationButtonStatesAndStationName];
    
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    FMAudioPlayerPlaybackState state = player.playbackState;
    
    if ((state == FMAudioPlayerPlaybackStateReadyToPlay) ||
        (state == FMAudioPlayerPlaybackStateComplete)) {
        // if we haven't started playback yet, then switch to this station so that
        // hitting the play button in the control area plays the visible station.
        [player setActiveStation:_stationPager.visibleStation];
    }

}

- (void) updateNavigationButtonStatesAndStationName {
    FMStation *visibleStation = _stationPager.visibleStation;
    [self updateNavigationButtonStatesAndStationNameToStation:  visibleStation];
}

- (void) updateNavigationButtonStatesAndStationNameToStation: (FMStation *) visibleStation {
    if (_visibleStations.count <= 1) {
        _leftButton.hidden = YES;
        _rightButton.hidden = YES;
        _stationLabel.text = visibleStation.name;
        return;
    }
    
    long index = [_visibleStations indexOfObject:visibleStation];
    
    if (index <= 0) {
        _leftButton.enabled = NO;
    } else {
        _leftButton.enabled = YES;
    }
    
    if (index >= (_visibleStations.count - 1)) {
        _rightButton.enabled = NO;
    } else {
        _rightButton.enabled = YES;
    }
    
    _stationLabel.text = visibleStation.name;
    
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    if ((visibleStation.isOnDemand) || (player.playHistory.count > 0)) {
        _playHistoryButton.enabled = YES;
    } else {
        _playHistoryButton.enabled = NO;
    }
}

- (void) moveLeftOneStation: (id) target {
    FMStation *visible = _stationPager.visibleStation;
    long index = [_visibleStations indexOfObject:visible];

    if (index > 0) {
        NSIndexPath *newVisibleIndex = [NSIndexPath indexPathForRow:index - 1 inSection:0];
        
        [_stationPager scrollToItemAtIndexPath:newVisibleIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

- (void) moveRightOneStation: (id) target {
    FMStation *visible = _stationPager.visibleStation;
    long index = [_visibleStations indexOfObject:visible];
    
    if (index < (_visibleStations.count - 1)) {
        NSIndexPath *newVisibleIndex = [NSIndexPath indexPathForRow:index + 1 inSection:0];
        
        [_stationPager scrollToItemAtIndexPath:newVisibleIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

- (void) scrollToActiveStation {
    FMStation *activeStation = [[FMAudioPlayer sharedPlayer] activeStation];
    
    [self scrollToStation:activeStation];
}

- (void) scrollToStation: (FMStation *) station {
    NSUInteger index = [_visibleStations indexOfObject:station];
    
    // we do not seem to have this station - sad!
    if (index == NSNotFound) {
        NSLog(@"did not find requested station!");
        return;
    }

    NSIndexPath *newVisibleIndex = [NSIndexPath indexPathForRow:index inSection:0];
    
    [_stationPager scrollToItemAtIndexPath:newVisibleIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

#pragma mark - Update lock screen

- (void) setupLockScreen {
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];

    [self assignLockScreenImageFromStation:player.activeStation];
    
    // watch for station changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeStationDidChange:) name:FMAudioPlayerActiveStationDidChangeNotification object:player];
}

- (void) activeStationDidChange: (NSNotification *)notification {
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    
    [self assignLockScreenImageFromStation:player.activeStation];
}

- (void) assignLockScreenImageFromStation: (FMStation *) station {
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    
    NSString *bgImageUrl = [station.options objectForKey:FMResources.backgroundImageUrlPropertyName];
    if (bgImageUrl) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:bgImageUrl]
                              options:0
                             progress:nil
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image) {
                                    [player setLockScreenImage:image];
                                }
                            }];
    }
}

#pragma mark - Metadata display

- (void)setupMetadata {
    // keep track of this!
    _defaultNoticeText = _noticeLabel.text;
    _noticeTimer = nil;
}

- (void)setupMetadataEventHandlers {
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    
    if (_noticeTimer != nil) {
        [_noticeTimer invalidate];
        _noticeTimer = nil;
    }

    // watch for player events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateUpdated:) name:FMAudioPlayerPlaybackStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skipFailed:) name:FMAudioPlayerSkipFailedNotification object:player];
    
    [self updateMetadataDisplay];
}

- (void) removeMetadataEventHandlers {
    // stop watching for player events
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) skipFailed: (NSNotification *) notification {
    [self displayNotice:@"Sorry, you've temporarily run out of skips"];
}

- (void) displayNotice: (NSString *) noticeText {
    if (_noticeTimer != nil) {
        [_noticeTimer invalidate];
        _noticeTimer = nil;
    }
    
    _trackLineOneLabel.hidden = YES;
    _trackLineTwoLabel.hidden = YES;
    _noticeLabel.text = noticeText;
    _noticeLabel.hidden = NO;

    _noticeTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(hideNotice:) userInfo:nil repeats:NO];
}

- (void) hideNotice: (NSTimer *)timer {
    _noticeTimer = nil;
    _noticeLabel.text = _defaultNoticeText;
    
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

#pragma mark - Play history toggling

- (void) setupPlayHistory {
    //[self hideHistoryAnimated:NO];

    // make sure playlist and playhistory are down below controls
    [self hideDrawer:_playHistoryView animated:NO];
    [self hideDrawer:_playlistView animated:NO];
    
    [_playHistoryView setTarget:self andSelectorForCloseButton:@selector(closeDrawer)];
    [_playlistView setTarget:self andSelectorForCloseButton:@selector(closeDrawer)];

    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];

    if ((player.playHistory.count > 0) || _initiallyVisibleStation.isOnDemand) {
        _playHistoryButton.enabled = YES;

    } else {
        _playHistoryButton.enabled = NO;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songStarted:) name:FMAudioPlayerCurrentItemDidBeginPlaybackNotification object:[FMAudioPlayer sharedPlayer]];
}

- (void) songStarted: (NSNotification *) notification {
    if (!_playHistoryButton.enabled) {
        _playHistoryButton.enabled = YES;
        _playHistoryButton.selected = YES;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:FMAudioPlayerCurrentItemDidBeginPlaybackNotification object:[FMAudioPlayer sharedPlayer]];
}

- (void) closeDrawer {
    [self togglePlaylistOrHistory:nil];
}

- (IBAction)togglePlaylistOrHistory:(id)sender {
    FMStation *station = [_stationPager visibleStation];

    if (station.isOnDemand) {
        _playlistView.station = station;
        
        NSArray *visible = _stationPager.visibleCells;
        if (visible.count == 1) {
            FMPageableStationCollectionViewStationCell *cell = [visible objectAtIndex:0];
            _playlistView.defaultAudioItemImage = cell.backgroundImage.image;
        }

        [_playlistView reloadData];
    }

    UIView *drawer = (station.isOnDemand ? _playlistView : _playHistoryView);

    if (_playHistoryButton.selected) {
        [self hideDrawer: drawer animated:YES];

    } else {
        [self showDrawer: drawer animated:YES];
    }
    
    _playHistoryButton.selected = !_playHistoryButton.selected;
}

- (void) hideDrawer: (UIView *) drawer animated: (BOOL) animated {
    if (!animated) {
        drawer.transform = CGAffineTransformMakeTranslation(0, _playerDisplayView.frame.size.height);
        _playerDisplayView.transform = CGAffineTransformMakeTranslation(0, 0);
        
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            drawer.transform = CGAffineTransformMakeTranslation(0, _playerDisplayView.frame.size.height);
            _playerDisplayView.transform = CGAffineTransformMakeTranslation(0, 0);
        }];
        
    }
}

- (void) showDrawer: (UIView *) drawer animated: (BOOL) animated {
    if (!animated) {
        drawer.transform = CGAffineTransformMakeTranslation(0, 0);
        _playerDisplayView.transform = CGAffineTransformMakeTranslation(0, _playerDisplayView.frame.size.height * -1);
        
    } else {
        [UIView animateWithDuration:0.5 animations:^{
            drawer.transform = CGAffineTransformMakeTranslation(0, 0);
            _playerDisplayView.transform = CGAffineTransformMakeTranslation(0, _playerDisplayView.frame.size.height * -1);
        }];
        
    }
}

#pragma mark - Sharing

- (IBAction)shareButton:(id)sender {
    FMStation *station = _stationPager.visibleStation;
    NSString *textToShare = [NSString stringWithFormat:@"Listening to '%@'", station.name];

    NSArray *objectsToShare = @[textToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypeOpenInIBooks,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
