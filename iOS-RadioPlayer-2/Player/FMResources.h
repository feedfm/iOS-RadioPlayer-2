//
//  FMResources.h
//  iOS-RadioPlayer
//
//  Created by Eric Lambrecht on 10/17/16.
//  Copyright © 2016 Eric Lambrecht. All rights reserved.
//

#import "FMPlayerViewController.h"
#import "FMStationCollectionViewController.h"
#import "FMPopUpDownNavigationController.h"
#import <FeedMedia/FeedMedia.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FMResources : NSObject

@property (class, nonatomic, assign, readonly) NSString *backgroundImageUrlPropertyName;
@property (class, nonatomic, assign, readonly) NSString *subheaderPropertyName;

+ (void) presentPlayerWithTitle:(NSString *)title;
+ (void) presentPlayerFromViewController: (UIViewController *) viewController withTitle:(NSString *)title;

+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title;
+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title showingStationNamed: (NSString *) stationName;
+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title
                                                showingStation: (FMStation *) station;

+ (FMStationCollectionViewController *) createStationCollectionViewControllerWithTitle: (NSString *) title;

+ (void) assignLockScreenImageFromStation: (FMStation *) station;

+ (UIStoryboard *)playerStoryboard;
+ (UIImage *)imageNamed:(NSString *)name;

@end
