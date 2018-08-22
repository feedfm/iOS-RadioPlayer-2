//
//  FMPlayHistoryCollectionView.m
//  iOS-RadioPlayer-2
//
//  Insert a UICollectionView in the interface builder, and assign it this
//  class. Then add a collection cell to represent each play, assign it
//  the FMPlayHistoryCollectionViewPlayCell class, and give it a reuse id
//  of 'playCell'. Then add a resuable view cell, assign it the
//  FMPlayHistoryCollectionViewStationCell class, and give it a reuse id
//  of 'stationCell'. Make sure to wire up all the UI elements, and you're
//  golden!
//
//  Created by Eric Lambrecht on 5/19/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "FMPlayHistoryCollectionView.h"
#import "FMResources.h"
#import <FeedMedia/FeedMedia.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+FMAdjustImageAlpha.h"

// Helper classes to represent a 'play' and a 'station' header.

@implementation FMPlayHistoryCollectionViewPlayCell

@end

@implementation FMPlayHistoryCollectionViewStationCell

@end

//
//
//

@interface FMPlayHistoryCollectionView ()

@property (weak, nonatomic) id closeTarget;
@property (nonatomic) SEL closeSelector;

@property (strong, nonatomic) UIImage *fadedLikeImage;
@property (strong, nonatomic) UIImage *fadedDislikeImage;

@end


@implementation FMPlayHistoryCollectionView {
    
    NSMutableArray *_audioItems;
    NSMutableArray *_stations;
    
}

static NSString * const playCellIdentifier = @"playCell";
static NSString * const stationCellIdentifier = @"stationCell";
static UIEdgeInsets sectionInsets;
static double itemHeight = 56.0;
static double sectionHeight = 65.0;

+ (void) initialize {
    if (self == [FMPlayHistoryCollectionView class]) {
        sectionInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    }
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

- (void) setup {
    _audioItems = [NSMutableArray new];
    _stations = [NSMutableArray new];
    
    // pull current play history into our data structure
    NSArray *playHistory = [[FMAudioPlayer sharedPlayer] playHistory];
    for (long int i = playHistory.count - 1; i >= 0; i--) {
        FMAudioItem *audioItem = [playHistory objectAtIndex:i];
        
        NSLog(@"audio item is %@, and station is %@", audioItem, audioItem.station);
        
        [self appendNewAudioItem:audioItem station:audioItem.station];
    }
    
    self.dataSource = self;
    self.delegate = self;
    
    // watch for updates to the play history
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songStarted:) name:FMAudioPlayerCurrentItemDidBeginPlaybackNotification object:[FMAudioPlayer sharedPlayer]];
    
    // no close targets by default
    _closeTarget = nil;
    _closeSelector = 0;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FMAudioPlayerCurrentItemDidBeginPlaybackNotification object:[FMAudioPlayer sharedPlayer]];
}


- (void) setTarget: (id) target andSelectorForCloseButton: (SEL) selector {
    _closeTarget = target;
    _closeSelector = selector;
}

- (void) songStarted: (NSNotification *) notification {
    FMAudioItem *currentItem = [[FMAudioPlayer sharedPlayer] currentItem];
    FMStation *activeStation = [[FMAudioPlayer sharedPlayer] activeStation];
    
    NSLog(@"'%@' started in '%@'", currentItem.name, activeStation.name);
    
    if (currentItem) {
        [self appendNewAudioItem:currentItem station:activeStation];
        [self reloadData];
    }
}

- (void) appendNewAudioItem: (FMAudioItem *) audioItem station: (FMStation *) station {
    FMStation *lastStation = (_stations.count > 0) ? ((FMStation *)_stations[0]) : nil;

    // stick play on existing station array, or create new one if on different station
    NSMutableArray *plays;
    if ((lastStation == nil) || ![lastStation.identifier isEqualToString:station.identifier]) {
        plays = [NSMutableArray new];
        [_audioItems insertObject:plays atIndex:0];
        
        [_stations insertObject:station atIndex:0];
        
    } else {
        FMAudioItem *lastSong = _audioItems[0][0];
        if ([lastSong.id isEqualToString:audioItem.id]) {
            // don't list a song twice (from simulcast stations)
            return;
        }

        plays = _audioItems[0];
    }
    
    [plays insertObject:audioItem atIndex:0];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _stations.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ((NSMutableArray *) _audioItems[section]).count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FMPlayHistoryCollectionViewPlayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:playCellIdentifier forIndexPath:indexPath];

    FMAudioItem *audioItem = (FMAudioItem *) _audioItems[indexPath.section][indexPath.row];

    UIFont *plainFont = cell.trackLabel.font;
    UIFont *boldFont = [UIFont fontWithDescriptor:[[plainFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:plainFont.pointSize];
    
    NSMutableAttributedString *trackString = [[NSMutableAttributedString alloc]initWithString: audioItem.name attributes: @{ NSFontAttributeName: boldFont }];
    
    NSMutableAttributedString *artistString = [[NSMutableAttributedString alloc] initWithString: [NSString stringWithFormat: @" · %@", audioItem.artist] attributes: @{ NSFontAttributeName: plainFont }];

    [trackString appendAttributedString: artistString];
    
    cell.trackLabel.attributedText = trackString;
    
    // by default, truncate titles. selecting title will animate it
    cell.trackLabel.labelize = YES;
    
    // fade out like/dislike buttons
    cell.likeButton.audioItem = audioItem;
    if (_fadedLikeImage == nil) {
        _fadedLikeImage = [[cell.likeButton imageForState:UIControlStateNormal] translucentImageWithAlpha:0.5];
    }
    [cell.likeButton setImage:_fadedLikeImage forState:UIControlStateNormal];
    
    cell.dislikeButton.audioItem = audioItem;
    if (_fadedDislikeImage == nil) {
        _fadedDislikeImage = [[cell.dislikeButton imageForState:UIControlStateNormal] translucentImageWithAlpha:0.5];
    }
    [cell.dislikeButton setImage:self.fadedDislikeImage forState:UIControlStateNormal];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {

        FMPlayHistoryCollectionViewStationCell * cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:stationCellIdentifier forIndexPath:indexPath];
        
        FMStation *station = (FMStation *) _stations[indexPath.section];
        
        cell.stationLabel.text = station.name;
        //cell.historyLabel.hidden = (indexPath.section > 0);
 
        NSString *bgImageUrl = [self backgroundImageURLForOptions:station.options];
        
        if (bgImageUrl != nil) {
            cell.stationImage.hidden = NO;
            [cell.stationImage sd_setImageWithURL:[NSURL URLWithString:bgImageUrl] ];
            
        } else {
            cell.stationImage.hidden = YES;
        }

        if (indexPath.section == 0) {
            cell.closeButton.hidden = NO;
            [cell.closeButton addTarget:self action:@selector(didTapCloseButton:) forControlEvents:UIControlEventTouchUpInside];
            
        } else {
            cell.closeButton.hidden = YES;
        }
        
        return cell;
        
    } else {
        
        return nil;
    }
}

- (NSString *) backgroundImageURLForOptions: (NSDictionary *) options {
    NSString *bgImageUrl = [options objectForKey:FMResources.backgroundLandscapeImageUrlPropertyName];
    
    if ((bgImageUrl != nil) && (bgImageUrl.length > 0)) {
        return bgImageUrl;
    }
    
    bgImageUrl = [options objectForKey:FMResources.backgroundImageUrlPropertyName];
    
    if ((bgImageUrl != nil) && (bgImageUrl.length > 0)) {
        return bgImageUrl;
    }
    
    return nil;
}


- (void) didTapCloseButton: (id) sender {
    
    // turn off all animation
    for (FMPlayHistoryCollectionViewPlayCell *cell in self.visibleCells) {
        cell.trackLabel.labelize = YES;
    }

    if (!_closeTarget) { return; }
    IMP imp = [_closeTarget methodForSelector:_closeSelector];
    void (*func)(id, SEL) = (void *)imp;
    func(_closeTarget, _closeSelector);
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FMPlayHistoryCollectionViewPlayCell *cell = (FMPlayHistoryCollectionViewPlayCell *) [collectionView cellForItemAtIndexPath:indexPath];
    
    // animate track name when selected
    cell.trackLabel.labelize = NO;
}

- (void)collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    FMPlayHistoryCollectionViewPlayCell *cell = (FMPlayHistoryCollectionViewPlayCell *) [collectionView cellForItemAtIndexPath:indexPath];
    
    // de-animate track name when deselected
    cell.trackLabel.labelize = YES;
}


#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // items are width of screen minus margin and static height
    float paddingSpace = sectionInsets.left + sectionInsets.right;
    float availableWidth = self.bounds.size.width - paddingSpace;

    return CGSizeMake(availableWidth, itemHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    
    // section headers are width of screen and static height
    float availableWidth = self.bounds.size.width;
    
    return CGSizeMake(availableWidth, sectionHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return sectionInsets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

@end
