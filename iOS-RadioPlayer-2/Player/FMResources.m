//
//  FMResources.m
//  iOS-RadioPlayer
//
//  Created by Eric Lambrecht on 10/17/16.
//  Copyright © 2016 Eric Lambrecht. All rights reserved.
//

#import "FMResources.h"
#import "FMPopUpDownNavigationController.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation FMResources

static NSString *_backgroundImageUrlPropertyName = @"background_image_url";
static NSString *_backgroundPortraitImageUrlPropertyName = @"background_portrait_image_url";
static NSString *_backgroundLandscapeImageUrlPropertyName = @"background_landscape_image_url";
static NSString *_subheaderPropertyName = @"subheader";

+ (NSString *) backgroundImageUrlPropertyName {
    return _backgroundImageUrlPropertyName;
}

+ (NSString *) backgroundPortraitImageUrlPropertyName {
    return _backgroundPortraitImageUrlPropertyName;
}

+ (NSString *) backgroundLandscapeImageUrlPropertyName {
    return _backgroundLandscapeImageUrlPropertyName;
}

+ (NSString *) subheaderPropertyName {
    return _subheaderPropertyName;
}

+ (void) presentPlayerFromViewController: (UIViewController *) viewController withTitle:(NSString *)title visibleStations:(FMStationArray *) visibleStations {

    // create player
    FMPlayerViewController *fmpvc = [FMResources createPlayerViewControllerWithTitle:title visibleStations:visibleStations];

    // stick player in pop-up navigation controller
    FMPopUpDownNavigationController *navController = [[FMPopUpDownNavigationController alloc] initWithRootViewController: fmpvc];
    
    // pop that sucker up!
    [viewController presentViewController:navController animated:YES completion:nil];
}

+ (void) presentPlayerWithTitle:(NSString *)title visibleStations:(FMStationArray *) visibleStations {
    [FMResources presentPlayerFromViewController:[FMResources topMostController] withTitle:title visibleStations:visibleStations];
}

+ (void) presentStationCollectionFromViewController: (UIViewController *) viewController withTitle:(NSString *)title visibleStations:visibleStations {
    
    // create player
    FMStationCollectionViewController *fmscvc = [FMResources createStationCollectionViewControllerWithTitle:title visibleStations:visibleStations];
    
    // stick player in pop-up navigation controller
    FMPopUpDownNavigationController *navController = [[FMPopUpDownNavigationController alloc] initWithRootViewController: fmscvc];
    
    // pop that sucker up!
    [viewController presentViewController:navController animated:YES completion:nil];
}

+ (void) presentStationCollectionWithTitle:(NSString *)title visibleStations:visibleStations {
    [FMResources presentStationCollectionFromViewController:[FMResources topMostController] withTitle:title visibleStations:visibleStations];
}

+ (UIViewController*) topMostController
{
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title visibleStations:(FMStationArray *)visibleStations {
    return [FMResources createPlayerViewControllerWithTitle:title showingStation:nil visibleStations:visibleStations];
}

+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title showingStationNamed: (NSString *) stationName visibleStations:(FMStationArray *)visibleStations {

    for (FMStation *station in [[FMAudioPlayer sharedPlayer] stationList]) {
        if ([station.name isEqualToString:stationName]) {
            return [FMResources createPlayerViewControllerWithTitle:title showingStation:station visibleStations:visibleStations];
        }
    }
    
    return [FMResources createPlayerViewControllerWithTitle:title showingStation:nil visibleStations:visibleStations];
}

+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title
                                                  showingStation: (FMStation *) station
                                                 visibleStations: (FMStationArray *)visibleStations {
    UIStoryboard *sb = [FMResources playerStoryboard];
    FMPlayerViewController *player = [sb instantiateViewControllerWithIdentifier:@"playerViewController"];
    
    player.title = title;
    player.initiallyVisibleStation = station;
    player.visibleStations = visibleStations;

    return player;
}

+ (FMStationCollectionViewController *) createStationCollectionViewControllerWithTitle: (NSString *) title visibleStations:(FMStationArray *)visibleStations {
    UIStoryboard *sb = [FMResources playerStoryboard];
    
    FMStationCollectionViewController *stationCollection = [sb instantiateViewControllerWithIdentifier:@"stationCollectionViewController"];
    stationCollection.title = title;
    stationCollection.visibleStations = visibleStations;
    
    return stationCollection;
}

+ (UIStoryboard *)playerStoryboard {
    return [FMResources storyboardWithName:@"FMPlayerStoryboard"];
}

+ (UIStoryboard *)storyboardWithName:(NSString *)name {
    return [UIStoryboard storyboardWithName:name bundle:[FMResources frameworkBundle]];
}

+ (NSBundle *)frameworkBundle {
    return [NSBundle bundleForClass:self.class];
}

+ (UIImage *)imageNamed:(NSString *)name {
    return [UIImage imageNamed:name];
}

@end
