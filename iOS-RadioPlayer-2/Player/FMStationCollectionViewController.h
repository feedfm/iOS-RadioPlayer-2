//
//  FMStationCollectionViewController.h
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/9/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMStationCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

/**
 * Return the array of stations that are visible to the
 * user.
 */

+ (NSArray *) extractVisibleStations;


@end
