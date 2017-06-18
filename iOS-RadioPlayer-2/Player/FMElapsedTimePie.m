//
//  FMElapsedTimePie.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 6/18/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "FMElapsedTimePie.h"

@interface FMElapsedTimePie ()

@property (strong, nonatomic) FMAudioPlayer *feedPlayer;


@end

@implementation FMElapsedTimePie {
    CAShapeLayer *_shapeLayer;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(elapsedTimeDidUpdate:) name:FMAudioPlayerTimeElapseNotification object:_feedPlayer];
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    [self updateDisplay];
}

- (void) elapsedTimeDidUpdate: (NSNotification *) NSNotification {
    [self updateDisplay];
}

- (void) updateDisplay {

    float radius = self.bounds.size.width / 2;
    
    NSTimeInterval currentPlaybackTime = _feedPlayer.currentPlaybackTime;
    NSTimeInterval currentItemDuration = _feedPlayer.currentItemDuration;

    float degreesComplete;
    if (currentItemDuration == 0) {
        degreesComplete = 0;
    } else {
        degreesComplete = (currentPlaybackTime / currentItemDuration) * 360;
    }
    
    //NSLog(@"rendering with %f degrees complete, and radius %f", degreesComplete, radius);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(radius, radius) radius:radius startAngle:(3.0/2.0 * M_PI) endAngle:((degreesComplete - 90) / 180.0 * M_PI) clockwise:YES];
    [path addLineToPoint:CGPointMake(radius, radius)];
    [path closePath];
    
    if (!_shapeLayer) {
        CAShapeLayer *fillLayer = [CAShapeLayer layer];
        fillLayer.path = path.CGPath;
        fillLayer.fillColor = self.tintColor.CGColor;
        //    fillLayer.fillRule = kCAFillRuleEvenOdd;
        //    fillLayer.opacity = 0.5;
        
        [self.layer addSublayer:fillLayer];
        
        _shapeLayer = fillLayer;
        
    } else {
        // just swap out updated path
        _shapeLayer.path = path.CGPath;
        
    }
}


@end
