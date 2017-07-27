//
//  FMStationImageView.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 7/26/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "FMStationImageView.h"
#import "FMResources.h"
#import <SDWebImage/SDWebImageManager.h>

@interface FMStationImageView ()

@property (strong, nonatomic) FMAudioPlayer *feedPlayer;
@property (strong, nonatomic) UIImage *defaultImage;
@property (strong, nonatomic) NSString *nowDisplaying;

@end

@implementation FMStationImageView

- (id) initWithImage:(UIImage *)image {
    if (self = [super initWithImage:image]) {
        [self setup];
    }
    
    return self;
}

- (id) initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    if (self = [super initWithImage:image highlightedImage:highlightedImage]) {
        [self setup];
    }
    
    return self;
}

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

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) setup {
    _feedPlayer = [FMAudioPlayer sharedPlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeStationUpdated:) name:FMAudioPlayerActiveStationDidChangeNotification object:_feedPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeSongUpdated:) name:
     FMAudioPlayerCurrentItemDidBeginPlaybackNotification object:_feedPlayer];
    
    [self updateImage];
}

- (void) activeStationUpdated: (NSNotification *) notification {
    [self updateImage];
}

- (void) activeSongUpdated: (NSNotification *) notification {
    [self updateImage];
}

- (void) updateImage {

    if (_station != nil) {
        NSString *toDisplay = nil;
        
        if ([_feedPlayer.activeStation isEqual:_station] &&
            (_feedPlayer.currentItem != nil)) {
            // display current song if it exists and we are active station
            toDisplay = [self backgroundImageURLForSong:_feedPlayer.currentItem];
        }
        
        if (toDisplay == nil) {
            // display station background if we're not displaying song background
            toDisplay = [self backgroundImageURLForStation:_station];
        }
        
        if ((toDisplay != nil) && [toDisplay isEqualToString:_nowDisplaying]) {
            // we're already displaying this URL!
            return;

        } else if (toDisplay != nil) {
            // load up the new item to display
            _nowDisplaying = toDisplay;

            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:toDisplay]
                                  options:0
                                 progress:nil
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                    // only update if we're still displaying this image
                                    if ([_nowDisplaying isEqualToString:toDisplay]) {
                                        if (image) {
                                            [super setImage:image];
                                        } else {
                                            [super setImage:_defaultImage];
                                        }
                                    }
                                }
             ];

            return;
        }
    }
    
    // by default, act like a normal UIImageView
    _nowDisplaying = nil;

    [super setImage:_defaultImage];
}

- (NSString *) backgroundImageURLForStation: (FMStation *) station {
    NSString *bgImageUrl = [station.options objectForKey:FMResources.backgroundImageUrlPropertyName];
    
    return bgImageUrl;
}

- (NSString *) backgroundImageURLForSong: (FMAudioItem *) song {
    NSString *bgImageUrl = [song.metadata objectForKey:FMResources.backgroundImageUrlPropertyName];
    
    return bgImageUrl;
}

- (void) setStation:(FMStation *)station {
    if (_station != station) {
        _station = station;

        [self updateImage];
    }
}

- (void) setImage:(UIImage *)image {
    // intercept call and use this as the 'default' image
    _defaultImage = image;
    
    [self updateImage];
}


@end
