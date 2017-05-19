//
//  FMPlayHistoryCollectionViewDataSource.h
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/17/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <FeedMedia/FeedMedia.h>

@interface FMPlayHistoryCollectionViewDataSource : NSObject <UICollectionViewDataSource>

- (id) initWithPlayHistory: (NSArray *) playHistory;

- (void) appendNewAudioItem: (FMAudioItem *) audioItem;

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

@end
