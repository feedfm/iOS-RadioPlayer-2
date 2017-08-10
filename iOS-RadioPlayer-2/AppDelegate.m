//
//  AppDelegate.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/2/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "AppDelegate.h"
#import <FeedMedia/FeedMedia.h>
#import "FMResources.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    FMLogSetLevel(FMLogLevelDebug);
    
    [FMAudioPlayer setClientToken:@"ondemand"
                           secret:@"ondemand"];
    
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    [player whenAvailable:^{
        NSLog(@"Available!");

        player.secondsOfCrossfade = 0.0;
        player.crossfadeInEnabled = YES;
        
        for (FMStation *station in [player stationList]) {
            if (station.isOnDemand) {
                NSLog(@"'%@' is on-demand, with songs:", station.name);
                for (FMAudioItem *audioItem in station.audioItems) {
                    NSLog(@"   '%@' by '%@'", audioItem.name, audioItem.artist);
                }
                
            } else {
                NSLog(@"'%@' is not on-demand", station.name);
            }
        }
        
    } notAvailable:^{
        NSLog(@"Unavailable!");
    }];
    
    return YES;
}

@end
