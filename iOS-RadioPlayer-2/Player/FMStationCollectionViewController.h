//
//  FMStationCollectionViewController.h
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/9/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FeedMedia/FeedMediaUI.h>
#import "FMElapsedTimePie.h"
#import <FSQCollectionViewAlignedLayout/FSQCollectionViewAlignedLayout.h>

@interface FMStationCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;

@property (weak, nonatomic) IBOutlet UIImageView *playImage;
@property (weak, nonatomic) IBOutlet FMEqualizer *equalizer;

@property (weak, nonatomic) IBOutlet UIView *whiteCircle;
@property (weak, nonatomic) IBOutlet FMElapsedTimePie *elapsedTimePie;

@property (weak, nonatomic) FMStation *station;

@end


@interface FMStationCollectionViewController : UICollectionViewController <FSQCollectionViewDelegateAlignedLayout>

/**
 * Return the array of stations that are visible to the
 * user.
 */

+ (NSArray *) extractVisibleStations;


@end
