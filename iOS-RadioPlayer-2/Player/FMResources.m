//
//  FMResources.m
//  iOS-RadioPlayer
//
//  Created by Eric Lambrecht on 10/17/16.
//  Copyright © 2016 Eric Lambrecht. All rights reserved.
//

#import "FMResources.h"

@implementation FMResources

static NSString *_backgroundImageUrlPropertyName = @"image";
static NSString *_subheaderPropertyName = @"subheader";

+ (NSString *) backgroundImageUrlPropertyName {
    return _backgroundImageUrlPropertyName;
}

+ (NSString *) subheaderPropertyName {
    return _subheaderPropertyName;
}

+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title {
    UIStoryboard *sb = [FMResources playerStoryboard];

    FMPlayerViewController *player = [sb instantiateViewControllerWithIdentifier:@"playerViewController"];
    player.title = title;
    
    return player;
}

+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title showingStationNamed: (NSString *) stationName {

    FMPlayerViewController *player = [FMResources createPlayerViewControllerWithTitle:title];

    for (FMStation *station in [[FMAudioPlayer sharedPlayer] stationList]) {
        if ([station.name isEqualToString:stationName]) {
            player.initiallyVisibleStation = station;
            return player;
        }
    }
    
    return player;
}

+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title
                                                showingStation: (FMStation *) station {
    FMPlayerViewController *player = [FMResources createPlayerViewControllerWithTitle:title];
    
    player.initiallyVisibleStation = station;

    return player;
}

+ (FMStationCollectionViewController *) createStationCollectionViewControllerWithTitle: (NSString *) title {
    UIStoryboard *sb = [FMResources playerStoryboard];
    
    FMStationCollectionViewController *stationCollection = [sb instantiateViewControllerWithIdentifier:@"stationCollectionViewController"];
    stationCollection.title = title;
    
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
