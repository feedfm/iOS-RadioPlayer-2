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
        FMLogDebug(@"updating station image for station '%@'", _station.name);
        
        NSString *toDisplay = nil;
        
        if ([_feedPlayer.activeStation isEqual:_station] &&
            (_feedPlayer.currentItem != nil)) {
            FMLogDebug(@"   .. selecting current song image");
            
            // display current song if it exists and we are active station
            toDisplay = [self backgroundImageURLForSong:_feedPlayer.currentItem];
        }
        
        if (toDisplay == nil) {
            FMLogDebug(@"   .. selecting station background");

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
                                    if ([self->_nowDisplaying isEqualToString:toDisplay]) {
                                        if (image) {
                                            [super setImage:image];
                                        } else {
                                            [super setImage:self->_defaultImage];
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

- (NSString *) backgroundImageURLForOptions: (NSDictionary *) options {
    NSString *bgImageUrl = nil;
    
    if (self.bounds.size.width > self.bounds.size.height) {
        bgImageUrl = [options objectForKey:FMResources.backgroundLandscapeImageUrlPropertyName];
        
    } else if (self.bounds.size.width < self.bounds.size.height) {
        bgImageUrl = [options objectForKey:FMResources.backgroundPortraitImageUrlPropertyName];
        
    }
    
    if ((bgImageUrl != nil) && (bgImageUrl.length > 0)) {
        return bgImageUrl;
    }
    
    bgImageUrl = [options objectForKey:FMResources.backgroundImageUrlPropertyName];
    
    if ((bgImageUrl != nil) && (bgImageUrl.length > 0)) {
        return bgImageUrl;
    }
    
    return nil;
}

- (NSString *) backgroundImageURLForStation: (FMStation *) station {
    return [self backgroundImageURLForOptions:station.options];
}

- (NSString *) backgroundImageURLForSong: (FMAudioItem *) song {
    return [self backgroundImageURLForOptions:song.metadata];
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
