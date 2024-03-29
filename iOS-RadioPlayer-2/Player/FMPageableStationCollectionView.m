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

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (FMStation *) visibleStation {
    UICollectionViewCell *visibleCell = [self visibleCell];
    
    if (!visibleCell) {
        return nil;
    }
    
    FMStation *station = [self stationForCell:visibleCell];
    
    return station;
}

- (FMStation *) stationForCell: (UICollectionViewCell *) cell {
    NSIndexPath *current = [self indexPathForCell:cell];
    NSInteger index = current.row;

    return (index < _visibleStations.count) ? _visibleStations[index] : nil;
}

- (UICollectionViewCell *) visibleCell {
    float offset = self.contentOffset.x;

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
    }

    return visibleCell;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _visibleStations.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    FMPageableStationCollectionViewStationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:stationCellIdentifier forIndexPath:indexPath];

    FMStation *station = _visibleStations[indexPath.row];
    
    // background image
    cell.backgroundImage.station = station;
    
    // gradient over background image
    if (!cell.backgroundImage.layer.sublayers) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        
        gradient.frame = CGRectMake(0, self.bounds.size.height - 300, self.bounds.size.width, 300);
        gradient.colors = @[(id)[UIColor clearColor].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.75].CGColor];
        
        [cell.backgroundImage.layer insertSublayer:gradient atIndex:0];        
    }

    // 'play' button
    cell.stationButton.station = station;
    cell.stationButton.layer.cornerRadius = 30;
    
    // exploding mask
    cell.explodingMask.station = station;
 
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
