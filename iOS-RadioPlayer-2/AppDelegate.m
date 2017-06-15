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
    
    [FMAudioPlayer setClientToken:@"demo"
                           secret:@"demo"];
    
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    [player whenAvailable:^{
        NSLog(@"Available!");

        player.secondsOfCrossfade = 0.0;
        player.crossfadeInEnabled = YES;
        
    } notAvailable:^{
        NSLog(@"Unavailable!");
    }];
    
    return YES;
}

@end
