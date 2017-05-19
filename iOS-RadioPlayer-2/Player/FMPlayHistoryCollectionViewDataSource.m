//
//  FMPlayHistoryCollectionViewDataSource.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/17/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "FMPlayHistoryCollectionViewDataSource.h"
#import "FMPlayHistoryCollectionViewPlayCell.h"
#import "FMPlayHistoryCollectionViewStationCell.h"
#import <FeedMedia/FeedMedia.h>

@implementation FMPlayHistoryCollectionViewDataSource {
    
    NSMutableArray *_stationsAndAudioItems;
}

static NSString * const playCellIdentifier = @"playCell";
static NSString * const stationCellIdentifier = @"stationCell";

- (id) initWithPlayHistory: (NSArray *) playHistory {
    if (self == [super init]) {
        [self setupWithPlayHistory: playHistory];
    }
    
    return self;
}

#pragma mark - Map play history to nested array

- (void) setupWithPlayHistory: (NSArray *) playHistory {
    _stationsAndAudioItems = [NSMutableArray new];
    
    for (long int i = playHistory.count - 1; i >= 0; i--) {
        FMAudioItem *audioItem = [playHistory objectAtIndex:i];
        
        [self appendNewAudioItem:audioItem];
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
    
    cell.label.text = [NSString stringWithFormat:@"track %@ by %@", audioItem.name, audioItem.artist];
    [cell.label invalidateIntrinsicContentSize];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

    NSLog(@"dequeueing station cell at section %ld, row %ld of kind '%@'", indexPath.section, indexPath.row, kind);
    
    FMPlayHistoryCollectionViewStationCell * cell =[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:stationCellIdentifier forIndexPath:indexPath];

    FMAudioItem *audioItem = (FMAudioItem *) _stationsAndAudioItems[indexPath.section][0];

    cell.label.text = [NSString stringWithFormat:@"station %@", audioItem.station.name];

    [cell.label invalidateIntrinsicContentSize];
    
    return cell;
}

@end
