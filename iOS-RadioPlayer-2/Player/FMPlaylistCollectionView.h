//
//  FMPlaylistCollectionView.h
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/19/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FeedMedia/FeedMedia.h>

// helper classes

@interface FMPlaylistCollectionViewAudioItemCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet FMMarqueeLabel *trackLabel;
@property (strong, nonatomic) IBOutlet FMMarqueeLabel *artistLabel;
@property (strong, nonatomic) IBOutlet FMLikeButton *likeButton;
@property (strong, nonatomic) IBOutlet FMDislikeButton *dislikeButton;
@property (strong, nonatomic) IBOutlet UIImageView *audioItemImage;
@property (strong, nonatomic) IBOutlet FMPlayPauseButton *playPauseButton;

@end

@interface FMPlaylistCollectionViewStationCell : UICollectionReusableView

@property (strong, nonatomic) IBOutlet UILabel *stationLabel;
@property (strong, nonatomic) IBOutlet UIImageView *stationImage;
@property (strong, nonatomic) IBOutlet UIButton *closeButton;

@end

//
//
//

@interface FMPlaylistCollectionView : UICollectionView <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (void) setTarget: (id) target andSelectorForCloseButton: (SEL) selector;

@property (strong, nonatomic) FMStation *station;
@property (strong, nonatomic) UIImage *defaultAudioItemImage;

@end
