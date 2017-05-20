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

// Helper classes to represent a 'play' and a 'station' header.

@implementation FMPlayHistoryCollectionViewPlayCell

@end

@implementation FMPlayHistoryCollectionViewStationCell

@end

//
//
//

@implementation FMPlayHistoryCollectionView {
    
    NSMutableArray *_stationsAndAudioItems;
}

static NSString * const playCellIdentifier = @"playCell";
static NSString * const stationCellIdentifier = @"stationCell";
static UIEdgeInsets sectionInsets;
static double itemHeight = 56.0;
static double sectionHeight = 66.0;

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
    _stationsAndAudioItems = [NSMutableArray new];

    // pull current play history into our data structure
    NSArray *playHistory = [[FMAudioPlayer sharedPlayer] playHistory];
    for (long int i = playHistory.count - 1; i >= 0; i--) {
        FMAudioItem *audioItem = [playHistory objectAtIndex:i];
        
        [self appendNewAudioItem:audioItem];
    }
    
    self.dataSource = self;
    self.delegate = self;
    
    // watch for updates to the play history
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songStarted:) name:FMAudioPlayerCurrentItemDidBeginPlaybackNotification object:[FMAudioPlayer sharedPlayer]];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FMAudioPlayerCurrentItemDidBeginPlaybackNotification object:[FMAudioPlayer sharedPlayer]];
}


- (void) songStarted: (NSNotification *) notification {
    FMAudioItem *currentItem = [[FMAudioPlayer sharedPlayer] currentItem];
    
    if (currentItem) {
        [self appendNewAudioItem:currentItem];
        [self reloadData];
    }
}

- (void) appendNewAudioItem: (FMAudioItem *) audioItem {
    FMStation *lastStation = (_stationsAndAudioItems.count > 0) ? ((FMAudioItem *)_stationsAndAudioItems[0][0]).station : nil;

    NSLog(@"appending %@ from station %@", audioItem.name, audioItem.station.name);
    
    // stick play on existing station array, or create new one if on different station
    NSMutableArray *plays;
    if ((lastStation == nil) || ![lastStation.identifier isEqualToString:audioItem.station.identifier]) {
        plays = [NSMutableArray new];
        
        [_stationsAndAudioItems insertObject:plays atIndex:0];
    } else {
        plays = _stationsAndAudioItems[0];
    }
    
    [plays insertObject:audioItem atIndex:0];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _stationsAndAudioItems.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return ((NSMutableArray *) _stationsAndAudioItems[section]).count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FMPlayHistoryCollectionViewPlayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:playCellIdentifier forIndexPath:indexPath];
    
    NSLog(@"dequeueing play cell at section %ld, row %ld", indexPath.section, indexPath.row);
    
    FMAudioItem *audioItem = (FMAudioItem *) _stationsAndAudioItems[indexPath.section][indexPath.row];
    
    cell.trackLabel.text = [NSString stringWithFormat:@"%@ by %@", audioItem.name, audioItem.artist];

    // by default, truncate titles. selecting title will animate it
    cell.trackLabel.labelize = YES;
    
    cell.likeButton.audioItem = audioItem;
    cell.dislikeButton.audioItem = audioItem;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        NSLog(@"dequeueing station cell at section %ld, row %ld of kind '%@'", indexPath.section, indexPath.row, kind);
        
        FMPlayHistoryCollectionViewStationCell * cell =[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:stationCellIdentifier forIndexPath:indexPath];
        
        FMAudioItem *audioItem = (FMAudioItem *) _stationsAndAudioItems[indexPath.section][0];
        FMStation *station = audioItem.station;
        
        cell.stationLabel.text = audioItem.station.name;
 
        NSString *bgImageUrl = [station.options objectForKey:FMResources.backgroundImageUrlPropertyName];
        
        if (bgImageUrl != nil) {
            cell.stationImage.hidden = NO;
            [cell.stationImage sd_setImageWithURL:[NSURL URLWithString:bgImageUrl] ];
            
        } else {
            cell.stationImage.hidden = YES;
        }

        if (indexPath.section == 0) {
            cell.closeButton.hidden = NO;
        } else {
            cell.closeButton.hidden = YES;
        }
        
        return cell;
        
    } else {
        
        return nil;
    }
}

#pragma mark - <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    FMPlayHistoryCollectionViewPlayCell *cell = (FMPlayHistoryCollectionViewPlayCell *) [collectionView cellForItemAtIndexPath:indexPath];
    
    // animate track name when selected
    cell.trackLabel.labelize = NO;
}


#pragma mark <UICollectionViewDelegateFlowLayout>

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
