//
//  FMResources.m
//  iOS-RadioPlayer
//
//  Created by Eric Lambrecht on 10/17/16.
//  Copyright © 2016 Eric Lambrecht. All rights reserved.
//

#import "FMResources.h"


@interface FMDismissingViewController : UIViewController

@end

@implementation FMDismissingViewController

- (void) viewWillAppear:(BOOL)animated {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end


@implementation FMResources

static NSString *_backgroundImageUrlPropertyName = @"background_image_url";
static NSString *_subheaderPropertyName = @"subheader";

+ (NSString *) backgroundImageUrlPropertyName {
    return _backgroundImageUrlPropertyName;
}

+ (NSString *) subheaderPropertyName {
    return _subheaderPropertyName;
}

+ (void) presentPlayerFromViewController: (UIViewController *) viewController withTitle:(NSString *)title {
    // create fake 'dismissing' view controller
    FMDismissingViewController *fmdvc = [[FMDismissingViewController alloc] init];
    fmdvc.title = @"";
    
    // create UINavigationController with dismisser as root
    UINavigationController *uinc = [[UINavigationController alloc] initWithRootViewController:fmdvc];

    // create real player and add to nav stack
    FMPlayerViewController *fmpvc = [FMResources createPlayerViewControllerWithTitle:title];
    
    [uinc pushViewController:fmpvc animated:NO];

    // present the player
    [viewController presentViewController:uinc animated:YES completion:nil];
}


+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title {
    return [FMResources createPlayerViewControllerWithTitle:title showingStation:nil];
}

+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title showingStationNamed: (NSString *) stationName {

    for (FMStation *station in [[FMAudioPlayer sharedPlayer] stationList]) {
        if ([station.name isEqualToString:stationName]) {
            return [FMResources createPlayerViewControllerWithTitle:title showingStation:station];
        }
    }
    
    return [FMResources createPlayerViewControllerWithTitle:title showingStation:nil];
}

+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title
                                                showingStation: (FMStation *) station {
    UIStoryboard *sb = [FMResources playerStoryboard];
    FMPlayerViewController *player = [sb instantiateViewControllerWithIdentifier:@"playerViewController"];
    
    player.title = title;
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
