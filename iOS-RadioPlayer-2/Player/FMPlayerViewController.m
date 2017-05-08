//
//  FMPlayerViewController.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/3/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "FMPlayerViewController.h"
#import "FMResources.h"
#import <MarqueeLabel/MarqueeLabel.h>
#import <FeedMedia/FeedMedia.h>
#import <FeedMedia/FeedMediaUI.h>
#import <SDWebImage/UIImageView+WebCache.h>

#define CALL_TO_ACTION @"Press play to start!"
#define BACKGROUND_IMAGE_URL_PROPERTY @"image"

@interface FMPlayerViewController ()

@property (strong, nonatomic) NSArray *visibleStations;

@property (strong, nonatomic) IBOutlet MarqueeLabel *noticeLabel;
@property (strong, nonatomic) IBOutlet FMMetadataLabel *trackLineOneLabel;
@property (strong, nonatomic) IBOutlet FMMetadataLabel *trackLineTwoLabel;
@property (strong, nonatomic) IBOutlet UIScrollView *stationScroller;
@property (strong, nonatomic) IBOutlet UIView *stationScrollerContent;
@property (strong, nonatomic) IBOutlet UIView *stationSizer;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;

@end

@implementation FMPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self extractVisibleStations];
    
    // populate the station scroller
    [self populateStationScroller];
    
    // manage station scrolling and switching
    [self setupStationScrolling];
}

- (void) extractVisibleStations {
    NSArray *stations = [FMAudioPlayer sharedPlayer].stationList;

    // for now, display all stations
    _visibleStations = [stations copy];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
 
    // watch for player events
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateUpdated:) name:FMAudioPlayerPlaybackStateDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skipFailed:) name:FMAudioPlayerSkipFailedNotification object:player];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // stop watching for player events
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Manage station scrolling

- (void) setupStationScrolling {
    // watch for taps on scroll buttons
    [_leftButton addTarget:self action:@selector(moveLeftOneStation:) forControlEvents:UIControlEventTouchUpInside];
    [_rightButton addTarget:self action:@selector(moveRightOneStation:) forControlEvents:UIControlEventTouchUpInside];
    
    // watch for station scroll events to update left/right button states
    _stationScroller.delegate = self;
    
    [self updateLeftRightButtonStates];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateLeftRightButtonStates];
}

- (void) updateLeftRightButtonStates {
    if (_visibleStations.count <= 1){
        _leftButton.hidden = YES;
        _rightButton.hidden = YES;
        return;
    }
    
    CGPoint offset = _stationScroller.contentOffset;
    float pageWidth = _stationSizer.bounds.size.width;
    int pageIndex = floor(offset.x / pageWidth);
    
    if (pageIndex == 0) {
        _leftButton.enabled = NO;
    } else {
        _leftButton.enabled = YES;
    }
    
    if (pageIndex >= (_visibleStations.count - 1)) {
        _rightButton.enabled = NO;
    } else {
        _rightButton.enabled = YES;
    }
}

- (void) moveLeftOneStation: (id) target {
    CGPoint offset = _stationScroller.contentOffset;
    float pageWidth = _stationSizer.bounds.size.width;
    int pageIndex = floor(offset.x / pageWidth);
    
    if (pageIndex == 0) {
        return;
    }
    pageIndex -= 1;
    
    CGPoint newOffset = CGPointMake(pageIndex * pageWidth, 0);
    
    [_stationScroller setContentOffset: newOffset animated:YES];
}

- (void) moveRightOneStation: (id) target {
    CGPoint offset = _stationScroller.contentOffset;
    float pageWidth = _stationSizer.bounds.size.width;
    int pageIndex = floor(offset.x / pageWidth);
    
    if (pageIndex >= (_visibleStations.count - 1)) {
        return;
    }
    
    pageIndex += 1;
    
    CGPoint newOffset = CGPointMake(pageIndex * pageWidth , 0);

    [_stationScroller setContentOffset: newOffset animated:YES];
}

#pragma mark - Populate station scroller with stations

- (void) populateStationScroller {
    // add a page for each station
    UIView *previousStation = nil;

    for (int i = 0; i < _visibleStations.count; i++) {
        FMStation *station = [_visibleStations objectAtIndex:i];
        
        NSLog(@"adding station '%@'", station.name);
        
        UIView *stationView = [[UIView alloc] init];
        stationView.backgroundColor = [UIColor blackColor];
        
        // background image
        NSString *bgImageUrl = [station.options objectForKey:BACKGROUND_IMAGE_URL_PROPERTY];
        if (bgImageUrl != nil) {
            UIImageView *backgroundImage = [[UIImageView alloc] init];
            
            backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
            backgroundImage.contentMode = UIViewContentModeScaleAspectFill;
            backgroundImage.clipsToBounds = YES;

            [stationView addSubview:backgroundImage];
            
            // background image fills whole station view
            [stationView addConstraint:[NSLayoutConstraint constraintWithItem:backgroundImage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:stationView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
            [stationView addConstraint:[NSLayoutConstraint constraintWithItem:backgroundImage attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:stationView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            [stationView addConstraint:[NSLayoutConstraint constraintWithItem:backgroundImage attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:stationView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
            [stationView addConstraint:[NSLayoutConstraint constraintWithItem:backgroundImage attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:stationView attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
            
            [backgroundImage sd_setImageWithURL:[NSURL URLWithString:bgImageUrl] ];
        }

        // station title
        UILabel *stationTitle = [[UILabel alloc] init];
        stationTitle.text = station.name;
        stationTitle.textColor = [UIColor whiteColor];
        stationTitle.textAlignment = NSTextAlignmentCenter;
        stationTitle.adjustsFontSizeToFitWidth = YES;
        
        [stationView addSubview:stationTitle];

        stationTitle.translatesAutoresizingMaskIntoConstraints = NO;

        [stationView addConstraint:[NSLayoutConstraint constraintWithItem:stationTitle
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:stationView
                                                                attribute:NSLayoutAttributeLeftMargin
                                                               multiplier:1
                                                                 constant:34]];
        [stationView addConstraint:[NSLayoutConstraint constraintWithItem:stationTitle
                                                                attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:stationView
                                                                attribute:NSLayoutAttributeRightMargin
                                                               multiplier:1
                                                                 constant:-34]];
        
        [stationView addConstraint:[NSLayoutConstraint constraintWithItem:stationTitle
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:stationView
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1
                                                                 constant:-30]];
        
        // 'STATION' label
        UILabel *stationLabel = [[UILabel alloc] init];
        NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
        stationLabel.attributedText = [[NSAttributedString alloc] initWithString:@"STATION"
                                                                      attributes:underlineAttribute];
        stationLabel.textColor = [UIColor whiteColor];
        stationLabel.textAlignment = NSTextAlignmentCenter;
        stationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        stationLabel.font = [UIFont systemFontOfSize:12];
        
        [stationView addSubview:stationLabel];
        [stationView addConstraint:[NSLayoutConstraint constraintWithItem:stationLabel
                                                                attribute:NSLayoutAttributeLeft
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:stationView
                                                                attribute:NSLayoutAttributeLeftMargin
                                                               multiplier:1
                                                                 constant:34]];
        [stationView addConstraint:[NSLayoutConstraint constraintWithItem:stationLabel
                                                                attribute:NSLayoutAttributeRight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:stationView
                                                                attribute:NSLayoutAttributeRightMargin
                                                               multiplier:1
                                                                 constant:-34]];

        [stationView addConstraint:[NSLayoutConstraint constraintWithItem:stationLabel
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:stationTitle
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1
                                                                 constant:0]];

        // station play button
        FMStationButton *playButton = [[FMStationButton alloc] init];
        UIImage *iconPlayBlack = [FMResources imageNamed:@"icon-play-black"];
        [playButton setImage:iconPlayBlack forState:UIControlStateNormal];
        playButton.playOnClick = YES;
        playButton.hideWhenActive = YES;
        playButton.station = station;
        
        float width = 60;
        playButton.layer.cornerRadius = width / 2.0f;
        playButton.clipsToBounds = true;
        playButton.backgroundColor = [UIColor whiteColor];
        
        [playButton setTranslatesAutoresizingMaskIntoConstraints:false];
        
        [stationView addSubview:playButton];
        
        // center of station view
        [stationView addConstraint:[NSLayoutConstraint constraintWithItem:playButton
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:stationView
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1
                                                                 constant:0]];
        [stationView addConstraint:[NSLayoutConstraint constraintWithItem:playButton
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:stationView
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1
                                                                 constant:0]];
        
        // width, height of 60points
        [stationView addConstraint:[NSLayoutConstraint constraintWithItem:playButton
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1
                                                                 constant:width]];
        [stationView addConstraint:[NSLayoutConstraint constraintWithItem:playButton
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeNotAnAttribute
                                                               multiplier:1
                                                                 constant:width]];
        
        // add station view to content view that has all stations
        [_stationScrollerContent addSubview:stationView];
        
        // station view sizing:
        
        stationView.translatesAutoresizingMaskIntoConstraints = NO;

        // top = same as content view
        [_stationScrollerContent addConstraint:[NSLayoutConstraint constraintWithItem:stationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_stationScrollerContent attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
        // bottom = same as content view
        [_stationScrollerContent addConstraint:[NSLayoutConstraint constraintWithItem:stationView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_stationScrollerContent attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
        
        // width = station sizer width
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:stationView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_stationSizer attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        // left = right of previous station or anchored to left side of content view
        if (previousStation == nil) {
            [_stationScrollerContent addConstraint:[NSLayoutConstraint constraintWithItem:stationView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:_stationScrollerContent attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
        } else {
            [_stationScrollerContent addConstraint:[NSLayoutConstraint constraintWithItem:stationView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:previousStation attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
        }
        
        previousStation = stationView;
    }
    
    // finally, the container is the width of all the stations together
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_stationScrollerContent attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:_stationSizer attribute:NSLayoutAttributeWidth multiplier:_visibleStations.count constant:0]];
    
    // and as tall as the station sizer
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_stationScrollerContent attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_stationSizer attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
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
