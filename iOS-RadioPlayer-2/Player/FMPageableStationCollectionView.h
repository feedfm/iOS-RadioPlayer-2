//
//  FMPageableStationCollectionView.h
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/24/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FeedMedia/FeedMedia.h>
#import <FeedMedia/FeedMediaUI.h>

@protocol FMPageableStationCollectionViewDelegate<NSObject>

- (void) visibleStationDidChange;

@end

@interface FMPageableStationCollectionViewStationCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *stationLabel;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (strong, nonatomic) IBOutlet FMStationButton *stationButton;

@end

@interface FMPageableStationCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSArray *visibleStations;
@property (strong, nonatomic) id<FMPageableStationCollectionViewDelegate> pageableStationDelegate;

- (FMStation *) visibleStation;

@end