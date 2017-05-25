//
//  FMPlayerViewController.h
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/3/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMPageableStationCollectionView.h"
#import <FeedMedia/FeedMedia.h>

@interface FMPlayerViewController : UIViewController <UIScrollViewDelegate, FMPageableStationCollectionViewDelegate>

@property (strong, nonatomic) FMStation *initiallyVisibleStation;

- (void) scrollToStation: (FMStation *) station;

@end
