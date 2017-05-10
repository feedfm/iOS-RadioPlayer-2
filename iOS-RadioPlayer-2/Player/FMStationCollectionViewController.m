//
//  FMStationCollectionViewController.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/9/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "FMStationCollectionViewController.h"
#import "FMStationCollectionViewCell.h"
#import "FMResources.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <FeedMedia/FeedMedia.h>

@interface FMStationCollectionViewController ()

@property (strong, nonatomic) NSArray *visibleStations;

@end

@implementation FMStationCollectionViewController
    
static NSString * const reuseIdentifier = @"stationCell";
static int stationsPerRow = 2;
static UIEdgeInsets sectionInsets;

+ (void) initialize {
    if (self == [FMStationCollectionViewController class]) {
        sectionInsets = UIEdgeInsetsMake(25.0, 10.0, 0.0, 10.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _visibleStations = [FMStationCollectionViewController extractVisibleStations];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];

    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    
    // watch for player state updates so we can update play/playing button states
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stationOrStateUpdated:) name:FMAudioPlayerActiveStationDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stationOrStateUpdated:) name:
     FMAudioPlayerPlaybackStateDidChangeNotification object:player];
  
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


+ (NSArray *) extractVisibleStations {
    NSArray *stations = [FMAudioPlayer sharedPlayer].stationList;
    
    // for now, display all stations
    return [stations copy];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _visibleStations.count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return _visibleStations.count;
    } else {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FMStationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    FMStation *station = [_visibleStations objectAtIndex:indexPath.row];
    
    cell.backgroundImage.backgroundColor = [UIColor blackColor];
    
    if (station) {
        NSLog(@"assigning text for %@", station.name);
        cell.station = station;
        cell.title.text = station.name;
        
        NSString *bgImageUrl = [station.options objectForKey:FMResources.backgroundImageUrlProperty];
        if (bgImageUrl) {
            [cell.backgroundImage sd_setImageWithURL:[NSURL URLWithString:bgImageUrl] ];
        }
        
        NSString *subheader = [station.options objectForKey:FMResources.subheaderProperty];
        if (subheader) {
            cell.subtitle.text = subheader;
        } else {
            cell.subtitle.text = @"";
        }
        
        FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
        
        // no buttons when not available
        if ((player.playbackState == FMAudioPlayerPlaybackStateUninitialized)
            || (player.playbackState == FMAudioPlayerPlaybackStateUnavailable)) {
            cell.playImage.hidden = YES;
            cell.equalizer.hidden = YES;
            
        // station is selected and playing
        } else if ([player.activeStation isEqual:station]
                   && (player.playbackState != FMAudioPlayerPlaybackStateComplete)
                   && (player.playbackState != FMAudioPlayerPlaybackStateReadyToPlay)
                   && (player.playbackState != FMAudioPlayerPlaybackStatePaused)) {
            cell.playImage.hidden = YES;
            cell.equalizer.hidden = NO;
            
        // station not selected or playing
        } else {
            cell.playImage.hidden = NO;
            cell.equalizer.hidden = YES;

        }
        
        cell.whiteCircle.layer.cornerRadius = 15.0f;
    }
    
    return cell;
}

- (void) stationOrStateUpdated: (NSNotification *)notification {
    // pick out the active station, and see if it's being displayed
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];

    // loop through all the visible stations and make sure they're displaying
    // the correct image
    for (FMStationCollectionViewCell *cell in self.collectionView.visibleCells) {
        bool active = [cell.station isEqual:player.activeStation];
        
        if (active && (player.playbackState != FMAudioPlayerPlaybackStateComplete)
            && (player.playbackState != FMAudioPlayerPlaybackStateReadyToPlay)
            && (player.playbackState != FMAudioPlayerPlaybackStatePaused)){
            cell.equalizer.hidden = NO;
            cell.playImage.hidden = YES;

        } else {
            cell.equalizer.hidden = YES;
            cell.playImage.hidden = NO;
        }
    }
    
}

#pragma mark <UICollecitonViewdelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    float paddingSpace = sectionInsets.left * (stationsPerRow + 1);
    float availableWidth = self.view.bounds.size.width - paddingSpace;
    float widthPerItem = availableWidth / stationsPerRow;
    
    return CGSizeMake(widthPerItem, widthPerItem);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    return sectionInsets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return sectionInsets.left;
}

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FMStation *station = [_visibleStations objectAtIndex:indexPath.row];

    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    
    [player setActiveStation:station];
    [player play];
    
    return YES;
}

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
