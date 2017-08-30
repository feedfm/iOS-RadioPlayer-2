//
//  FMStationImageView.h
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 7/26/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FeedMedia/FeedMedia.h>


/**
 * This class updates its image to match the station passed to it or,
 * if the station is active, any image associated the current song.
 *
 * This class monitors active station and song changes, and updates
 * its image accordingly.
 *
 * Absent a 'station' value, this behaves as a normal UIImageView.
 */


@interface FMStationImageView : UIImageView


@property (nonatomic, strong) FMStation *station;

@end
