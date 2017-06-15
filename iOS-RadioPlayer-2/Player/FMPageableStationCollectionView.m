//
//  FMPageableStationCollectionView.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/24/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "FMPageableStationCollectionView.h"
#import "FMResources.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <FeedMedia/FeedMedia.h>

@implementation FMPageableStationCollectionViewStationCell

@end

@implementation FMPageableStationCollectionView

static NSString * const stationCellIdentifier = @"stationCell";

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
    self.dataSource = self;
    self.delegate = self;
}

- (FMStation *) visibleStation {
    float offset = self.contentOffset.x;
    long index = 0;
    
    if (offset > 0) {
        // loop through visible cells and find the one whose center
        // is closest to center of display
        UICollectionViewCell *visibleCell = nil;
        float visibleDistance = 0;
        
        // find cell whose center is closest to screen center
        for (UICollectionViewCell *cell in self.visibleCells){
            float center = cell.frame.origin.x + (cell.bounds.size.width / 2);
            float distance = fabs(center - (offset + (self.bounds.size.width / 2)));
            
            if ((visibleCell == nil) || (distance < visibleDistance)) {
                visibleCell = cell;
                visibleDistance = distance;
            }
            
            //NSLog(@"   cell with center %f and distance %f %@", center, distance, (cell == visibleCell) ? @"*" : @"");
        }
        
        NSIndexPath *current = [self indexPathForCell:visibleCell];
        index = current.row;
    }

    return (index < _visibleStations.count) ? _visibleStations[index] : nil;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _visibleStations.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    FMPageableStationCollectionViewStationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stationCellIdentifier forIndexPath:indexPath];

    FMStation *station = _visibleStations[indexPath.row];
    
    // background image
    NSString *bgImageUrl = [station.options objectForKey:FMResources.backgroundImageUrlPropertyName];
    if (bgImageUrl != nil) {
        [cell.backgroundImage sd_setImageWithURL:[NSURL URLWithString:bgImageUrl] ];

    } else {
        cell.backgroundImage.image = nil;
    }
    
    cell.stationButton.station = station;
    
    // make 'play' button a circle
    cell.stationButton.layer.cornerRadius = 30;

    return cell;
}

#pragma mark - <UICollectionViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_pageableStationDelegate) {
        [_pageableStationDelegate visibleStationDidChange];
    }
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // station fills entire display
    return self.bounds.size;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {

    return UIEdgeInsetsZero;
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
