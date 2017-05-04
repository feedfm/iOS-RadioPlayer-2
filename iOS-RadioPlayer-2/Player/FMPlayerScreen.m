//
//  FMPlayerScreen.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/4/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "FMPlayerScreen.h"

@interface FMPlayerScreen ()

@property (strong, nonatomic) FMAudioPlayer *feedPlayer;

@end

@implementation FMPlayerScreen

- (id) initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    
    return self;
}

- (id) init {
    if (self = [super init]) {
        [self setup];
    }
    
    return self;
}

- (void) setup {
    _feedPlayer = [FMAudioPlayer sharedPlayer];
    
    [self setupSubviews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateUpdated:) name:FMAudioPlayerPlaybackStateDidChangeNotification object:self.feedPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skipFailed:) name:FMAudioPlayerSkipFailedNotification object:self.feedPlayer];
}

- (void) setupSubviews {
    // configure ourselves as a vertical stack view
    self.axis = UILayoutConstraintAxisVertical;
    self.alignment = OAStackViewAlignmentCenter;
    self.spacing = 5.0f;
    self.distribution = OAStackViewDistributionEqualSpacing;

    // notice line - for call to action and flash notices
    _noticeLine = [[MarqueeLabel alloc] init];
    _noticeLine.textAlignment = NSTextAlignmentCenter;
    [_noticeLine setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self addSubview:_noticeLine];

    // trackLineOne and trackLineTwo - for current song metadata
    _trackLineOne = [[FMMetadataLabel alloc] init];
    _trackLineOne.textAlignment = NSTextAlignmentCenter;
    [_trackLineOne setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:_trackLineOne];

    _trackLineTwo = [[FMMetadataLabel alloc] init];
    _trackLineTwo.textAlignment = NSTextAlignmentCenter;
    [_trackLineTwo setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self addSubview:_trackLineTwo];

    // default format for track info
    self.trackLineOneFormat = @"%TRACK";
    self.trackLineTwoFormat = @"%ARTIST on %ALBUM";
    self.callToAction = @"Press play to start!";
    
    // update display will have been called from assignment above
}

- (void) setCallToAction:(NSString *)callToAction {
    _callToAction = callToAction;
    
    [self updateDisplay];
}

- (void) setTrackLineOneFormat:(NSString *)trackLineOneFormat {
    _trackLineOneFormat = trackLineOneFormat;
    _trackLineOne.format = trackLineOneFormat;
    
    [self updateDisplay];
}

- (void) setTrackLineTwoFormat:(NSString *)trackLineTwoFormat {
    _trackLineTwoFormat = trackLineTwoFormat;
    _trackLineTwo.format = trackLineTwoFormat;
    
    [self updateDisplay];
}

- (void) skipFailed: (NSNotification *) notification {
    
    [self updateDisplay];
}

- (void) stateUpdated: (NSNotification *) notification {
    
    [self updateDisplay];
}

- (void) updateDisplay {
    FMAudioPlayerPlaybackState state = _feedPlayer.playbackState;
    
    switch (state) {
        case FMAudioPlayerPlaybackStatePaused:
        case FMAudioPlayerPlaybackStatePlaying:
        case FMAudioPlayerPlaybackStateStalled:
        case FMAudioPlayerPlaybackStateRequestingSkip:
            // show track info
            _trackLineOne.hidden = NO;
            _trackLineTwo.hidden = NO;
            _noticeLine.hidden = YES;
            break;
            
        case FMAudioPlayerPlaybackStateComplete:
        case FMAudioPlayerPlaybackStateReadyToPlay:
            // show call to action
            _trackLineOne.hidden = YES;
            _trackLineTwo.hidden = YES;
            
            _noticeLine.text = _callToAction;
            _noticeLine.hidden = NO;
            break;
            
        case FMAudioPlayerPlaybackStateUnavailable:
        case FMAudioPlayerPlaybackStateUninitialized:
        case FMAudioPlayerPlaybackStateWaitingForItem:
            // show nothing!
            _trackLineOne.hidden = YES;
            _trackLineTwo.hidden = YES;
            _noticeLine.hidden = YES;
            break;
    }
}

@end
