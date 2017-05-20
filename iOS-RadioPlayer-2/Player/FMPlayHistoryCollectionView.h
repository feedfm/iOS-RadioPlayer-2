//
//  FMPlayHistoryCollectionView.h
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/19/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FeedMedia/FeedMediaUI.h>
#import <MarqueeLabel/MarqueeLabel.h>

// helper classes

@interface FMPlayHistoryCollectionViewPlayCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet MarqueeLabel *trackLabel;
@property (strong, nonatomic) IBOutlet FMLikeButton *likeButton;
@property (strong, nonatomic) IBOutlet FMDislikeButton *dislikeButton;

@end

@interface FMPlayHistoryCollectionViewStationCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *stationLabel;
@property (strong, nonatomic) IBOutlet UIImageView *stationImage;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;

@end

//
//
//

@interface FMPlayHistoryCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>


@end
