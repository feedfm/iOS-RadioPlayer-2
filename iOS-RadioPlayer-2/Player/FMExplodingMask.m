//
//  FMExplodingMask.m
//  iOS-RadioPlayer-2
//
//  This view is associated with an FMStation.
//
//  When the station is active and playing music or paused in a song,
//  the view is transparent.
//
//  When the station is not active or music playback hasn't begun or
//  has completed, this view covers it's whole area with a mask except
//  for a 200pt diameter circle in its center.
//
//  When the view transitions from one state to the other, it animates
//  that transparent circle in or out.
//
//  Created by Eric Lambrecht on 6/17/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "FMExplodingMask.h"

@interface FMExplodingMask ()

@property (strong, nonatomic) FMAudioPlayer *feedPlayer;

@end



@implementation FMExplodingMask {
    CATransform3D _untunedTransform;
    CATransform3D _tunedTransform;
    CALayer *_shadeLayer;
    CGRect _recentBounds;
    
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
    self.opaque = NO;
    
    // we keep track of when the bounds of the view change, so we can recreate
    // our mask
    _recentBounds = CGRectZero;
    
    _feedPlayer = [FMAudioPlayer sharedPlayer];
    
    // watch for changes in active station and playback state
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateOrStationDidUpdate:) name:FMAudioPlayerActiveStationDidChangeNotification object:_feedPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateOrStationDidUpdate:) name:
     FMAudioPlayerPlaybackStateDidChangeNotification object:_feedPlayer];

    // use this transform when the station is not tuned
    _untunedTransform = CATransform3DIdentity;
}

- (void) setStation:(FMStation *)station {
    _station = station;
    //NSLog(@"%@ assigned new cell", _station.name);
          
    [self updateDisplayAnimated: NO];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    // remove any old sublayer we built
    if (_shadeLayer) {
        if (CGRectEqualToRect(self.bounds, _recentBounds)) {
            // nothing changed, so nothing to do
            //NSLog(@"ignoring layout change");
            return;
        }
        
        /*
        NSLog(@"%@ recreating layer because of bounds change from %f, %f to %f, %f", _station.name,
              _recentBounds.size.width, _recentBounds.size.height,
              self.bounds.size.width, self.bounds.size.height);
         */
        
        [_shadeLayer removeFromSuperlayer];
        _shadeLayer = nil;

    } else {
        //NSLog(@"%@ creating new layer", _station.name);

    }

    _recentBounds = self.bounds;

    // sublayer with hole poking through it
    int radius = 100;
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake((self.bounds.size.width - (2 * radius)) / 2, (self.bounds.size.height - (2 * radius)) / 2, 2.0*radius, 2.0*radius) cornerRadius:radius];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.5;
    [self.layer addSublayer:fillLayer];
    
    _shadeLayer = fillLayer;
    
    // use this transform when the station is tuned
    CATransform3D tr = CATransform3DIdentity;
    tr = CATransform3DTranslate(tr, self.bounds.size.width/2, self.bounds.size.height/2, 0);

    // pythagorean theorem FTW!
    float scale = sqrtf(((self.bounds.size.width / 2) * (self.bounds.size.width / 2))
                        + ((self.bounds.size.height / 2) * (self.bounds.size.height / 2))) / radius;
    
    tr = CATransform3DScale(tr, scale, scale, 1);
    tr = CATransform3DTranslate(tr, -self.bounds.size.width/2, -self.bounds.size.height/2, 0);
    _tunedTransform = tr;
    
    [self updateDisplayAnimated: NO];
}

- (void) stateOrStationDidUpdate: (NSNotification *) notification {
    //NSLog(@"%@ state updated", _station.name);
    
    [self updateDisplayAnimated: YES];
}

- (void) updateDisplayAnimated: (BOOL) animated {
    BOOL stationIsActive = (_station == _feedPlayer.activeStation);

    BOOL displayIsTuned = [_shadeLayer.animationKeys containsObject:@"tuning"] ||  CATransform3DEqualToTransform(_shadeLayer.transform, _tunedTransform);
    
    // if station isn't the active one, make sure it is in the 'untuned' state
    if (!stationIsActive) {
        if (displayIsTuned) {
            [_shadeLayer removeAllAnimations];
            [self unTuneDisplayAnimated: animated];
            
        } else {
            //NSLog(@"%@ no display update", _station.name);
            
        }
        
        return;
    }
    
    BOOL stationIsTuned = (_feedPlayer.playbackState != FMAudioPlayerPlaybackStateReadyToPlay) &&
                         (_feedPlayer.playbackState != FMAudioPlayerPlaybackStateComplete);

    if (stationIsTuned && !displayIsTuned) {
        [_shadeLayer removeAllAnimations];
        [self tuneDisplayAnimated:animated];
        
    } else if (!stationIsTuned && displayIsTuned) {
        [_shadeLayer removeAllAnimations];
        [self unTuneDisplayAnimated:animated];
        
    } else {
        //NSLog(@"%@ no display update", _station.name);

    }
    
}

- (void) tuneDisplayAnimated: (BOOL) animated {
    if (animated) {
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
        scale.fromValue = [NSValue valueWithCATransform3D:_untunedTransform];
        scale.toValue = [NSValue valueWithCATransform3D:_tunedTransform];
        
        [_shadeLayer addAnimation:scale forKey:@"tuning"];
        
        //NSLog(@"%@ animated TUNE", _station.name);

    } else {
        //NSLog(@"%@ TUNE", _station.name);
        
    }
    
    // final state of layer is 'tuned'
    _shadeLayer.transform = _tunedTransform;
}

- (void) unTuneDisplayAnimated: (BOOL) animated {
    if (animated) {
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
        scale.fromValue = [NSValue valueWithCATransform3D:_tunedTransform];
        scale.toValue = [NSValue valueWithCATransform3D:_untunedTransform];
        
        [_shadeLayer addAnimation:scale forKey:@"untuning"];
        
        //NSLog(@"%@ animated UNTUNE", _station.name);
        
    } else {
        //NSLog(@"%@ UNTUNE", _station.name);
        
    }
    
    // final state of layer is 'untuned'
    _shadeLayer.transform = _untunedTransform;
}

@end
