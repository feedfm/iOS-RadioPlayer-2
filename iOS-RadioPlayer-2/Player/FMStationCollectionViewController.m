//
//  FMStationCollectionViewController.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/9/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "FMStationCollectionViewController.h"
#import "FMPlayerViewController.h"
#import "FMResources.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <FeedMedia/FeedMedia.h>


@implementation FMStationCollectionViewCell

@end


@interface FMStationCollectionViewController ()

@end

@implementation FMStationCollectionViewController
    
static NSString * const reuseIdentifier = @"stationCell";
static int stationsPerRow = 2;
static CGFloat itemSpacing = 20.0;
static CGFloat lineSpacing = 15.0;
static UIEdgeInsets sectionInsets;
static UIEdgeInsets cellInsets;

+ (void) initialize {
    if (self == [FMStationCollectionViewController class]) {
        sectionInsets = UIEdgeInsetsMake(20.0, 15.0, 0.0, 15.0);
        cellInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    }
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // **NOTE** - somebody had better set the visibleStations property
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];

    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    
    // watch for player state updates so we can update play/playing button states
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stationOrStateUpdated:) name:FMAudioPlayerActiveStationDidChangeNotification object:player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stationOrStateUpdated:) name:FMAudioPlayerPlaybackStateDidChangeNotification object:player];
    
    // when we return to the view, the equalizer animation dies, so
    // try to restart it here
    [self refreshButtonStates];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    return 1;
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
        cell.station = station;
        
        NSString *subheader = [station.options objectForKey:FMResources.subheaderPropertyName];
        if (subheader) {
            cell.subtitle.text = subheader;
        } else {
            cell.subtitle.text = @"";
        }

        cell.title.text = station.name;
        
        NSString *bgImageUrl = [self backgroundImageURLForOptions:station.options];
        if (bgImageUrl) {
            [cell.backgroundImage sd_setImageWithURL:[NSURL URLWithString:bgImageUrl] ];
        }
        
        FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];

        cell.elapsedTimePie.layer.cornerRadius = cell.elapsedTimePie.bounds.size.width / 2.0f;

        // no buttons when not available
        if ((player.playbackState == FMAudioPlayerPlaybackStateUninitialized)
            || (player.playbackState == FMAudioPlayerPlaybackStateUnavailable)) {
            cell.equalizer.hidden = YES;
            cell.playImage.hidden = YES;
            cell.elapsedTimePie.hidden = YES;
            
        // station is selected and playing
        } else if ([player.activeStation isEqual:station]
                   && (player.playbackState != FMAudioPlayerPlaybackStateComplete)
                   && (player.playbackState != FMAudioPlayerPlaybackStateReadyToPlay)
                   && (player.playbackState != FMAudioPlayerPlaybackStatePaused)) {
            cell.equalizer.hidden = NO;
            cell.playImage.hidden = YES;
            cell.elapsedTimePie.hidden = NO;
          
        // station is selected an paused
        } else if ([player.activeStation isEqual:station]
                   && (player.playbackState == FMAudioPlayerPlaybackStatePaused)) {
            cell.equalizer.hidden = YES;
            cell.playImage.hidden = NO;
            cell.elapsedTimePie.hidden = NO;
        
        // station not selected or playing
        } else {
            cell.equalizer.hidden = YES;
            cell.playImage.hidden = NO;
            cell.elapsedTimePie.hidden = YES;

        }
        
        UIView *whiteCircle = cell.whiteCircle;
        whiteCircle.layer.cornerRadius = whiteCircle.bounds.size.width / 2.0f;
        
        // and a drop shadow
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithOvalInRect:whiteCircle.bounds];
        whiteCircle.layer.masksToBounds = NO;
        whiteCircle.layer.shadowColor = [UIColor blackColor].CGColor;
        whiteCircle.layer.shadowOffset = CGSizeMake(2.0, 2.0);
        whiteCircle.layer.shadowOpacity = 0.5f;
        whiteCircle.layer.shadowPath = shadowPath.CGPath;

        cell.backgroundImage.layer.cornerRadius = 3.0f;
        cell.backgroundImage.layer.masksToBounds = YES;
    }
    
    return cell;
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


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"stationHeader" forIndexPath:indexPath];

        return cell;
        
    } else {
        assert(false);
        
    }
    
}

- (void) stationOrStateUpdated: (NSNotification *)notification {
    [self refreshButtonStates];
}

- (void) refreshButtonStates {
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
            [cell.equalizer startAnimation];
            cell.playImage.hidden = YES;
            cell.elapsedTimePie.hidden = NO;

        } else if (active && (player.playbackState == FMAudioPlayerPlaybackStatePaused)) {
            cell.equalizer.hidden = YES;
            [cell.equalizer stopAnimation];
            cell.playImage.hidden = NO;
            cell.elapsedTimePie.hidden = NO;
        
        } else {
            cell.equalizer.hidden = YES;
            [cell.equalizer stopAnimation];
            cell.playImage.hidden = NO;
            cell.elapsedTimePie.hidden = YES;
        }
    }
    
}

#pragma mark <FSQCollectionViewDelegateAlignedLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(FSQCollectionViewAlignedLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
      remainingLineSpace:(CGFloat)remainingLineSpace {

    float paddingSpace = itemSpacing * (stationsPerRow - 1);
    float availableWidth = self.view.bounds.size.width - paddingSpace;
    float insets = sectionInsets.left + sectionInsets.right;
    float bonus = 10.0; // what is this?
    float widthPerItem = (availableWidth - insets - bonus) / stationsPerRow;

    FMStation *station = [_visibleStations objectAtIndex:indexPath.row];

    // calculate height of station title
    NSMutableDictionary *titleAttr = [NSMutableDictionary dictionary];
    UIFont *titleFont = [UIFont systemFontOfSize: 15.0f weight:UIFontWeightBold];
    [titleAttr setObject:titleFont forKey:NSFontAttributeName];
    
    NSMutableParagraphStyle *titleParaStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    titleParaStyle.lineBreakMode = NSLineBreakByWordWrapping;

    CGFloat titleHeight = [station.name boundingRectWithSize:(CGSize) { widthPerItem, CGFLOAT_MAX }
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:titleAttr context:nil].size.height;
    
    float height = (.75 * widthPerItem) + 12.0f + titleHeight;

    // subheader height
    NSString *subheader = [station.options objectForKey:FMResources.subheaderPropertyName];
    
    if (subheader) {
        NSMutableDictionary *attr = [NSMutableDictionary dictionary];
        
        // subheader font
        UIFont *subheaderFont = [UIFont systemFontOfSize: 12.0f];
        [attr setObject:subheaderFont forKey:NSFontAttributeName];
        
        // word wrapping
        NSMutableParagraphStyle *paraStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
        [attr setObject:paraStyle forKey:NSParagraphStyleAttributeName];
        
        CGFloat subheaderHeight = [subheader boundingRectWithSize:(CGSize){ widthPerItem, CGFLOAT_MAX }
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:attr
                                                      context:nil].size.height;
        subheaderHeight = ceil(subheaderHeight);
        
        height += subheaderHeight;

    } else {
        // don't add any height for empty subheader
        
    }
    
    return CGSizeMake(widthPerItem, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceHeightForHeaderInSection:(NSInteger)section {
    return 0.0;
}

- (FSQCollectionViewAlignedLayoutSectionAttributes *)collectionView:(UICollectionView *)collectionView
                                                             layout:(FSQCollectionViewAlignedLayout *)collectionViewLayout
                                        attributesForSectionAtIndex:(NSInteger)sectionIndex {
    return [FSQCollectionViewAlignedLayoutSectionAttributes withHorizontalAlignment:FSQCollectionViewHorizontalAlignmentLeft
                                                                  verticalAlignment:FSQCollectionViewVerticalAlignmentTop
                                                                        itemSpacing:itemSpacing
                                                                        lineSpacing:lineSpacing
                                                                             insets:sectionInsets];
}

- (FSQCollectionViewAlignedLayoutCellAttributes *)collectionView:(UICollectionView *)collectionView
                                                          layout:(FSQCollectionViewAlignedLayout *)collectionViewLayout
                                    attributesForCellAtIndexPath:(NSIndexPath *)indexPath {
    
    return [FSQCollectionViewAlignedLayoutCellAttributes withInsets:cellInsets
            shouldBeginLine:NO
            shouldEndLine:NO
            startLineIndentation:NO];
    
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FMStation *station = [_visibleStations objectAtIndex:indexPath.row];

    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];

    if (!station.isOnDemand) {
        // switch to and auto play non-on-demand stations
        if (![player.activeStation isEqual:station]) {
            [player setActiveStation:station];
        }
        
        if ((player.playbackState == FMAudioPlayerPlaybackStateReadyToPlay) ||
            (player.playbackState == FMAudioPlayerPlaybackStateComplete) ||
            (player.playbackState == FMAudioPlayerPlaybackStatePaused)) {
            [player play];
        }
    }
    
    // kick off display of the selected station
    NSArray *viewControllers = self.navigationController.viewControllers;
    unsigned long viewControllerCount = viewControllers.count;
    
    UIStoryboard *sb = [FMResources playerStoryboard];

    if (viewControllerCount == 1) {
        // we're the only view controller, so create a player and push to it
        FMPlayerViewController *player = [sb instantiateViewControllerWithIdentifier:@"playerViewController"];
        player.title = self.title;
        player.initiallyVisibleStation = station;
        player.visibleStations = self.visibleStations;
        
        [self.navigationController pushViewController:player animated:YES];
        
    } else {
        UIViewController *parent = [viewControllers objectAtIndex:(viewControllerCount - 2)];

        if ([parent isKindOfClass:[FMPlayerViewController class]]) {
            // the parent view controller is a player, so pop() to it

            // (after switching the display to the new station)
            FMPlayerViewController *fmParent = (FMPlayerViewController *) parent;
            fmParent.initiallyVisibleStation = station;

            [self.navigationController popViewControllerAnimated:YES];
            
        } else {
            // else create a new player, and push to it
            FMPlayerViewController *player = [sb instantiateViewControllerWithIdentifier:@"playerViewController"];
            player.title = self.title;
            player.initiallyVisibleStation = station;
            player.visibleStations = self.visibleStations;

            [self.navigationController pushViewController:player animated:YES];            
        }
        
    }
    
    return YES;
}


@end
