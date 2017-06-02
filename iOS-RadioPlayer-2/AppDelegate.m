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

    [FMAudioPlayer setClientToken:@"counting"
                           secret:@"counting"];
    
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    [player whenAvailable:^{
        NSLog(@"Available!");
        
        // optionally turn on music crossfading
        player.crossfadeInEnabled = YES;
        player.secondsOfCrossfade = 0.0;
        
    } notAvailable:^{
        NSLog(@"Unavailable!");
    }];
    
    player.statusBarNotification.notificationTappedBlock = ^{
        [FMResources presentPlayerWithTitle:@"pop-up music"];
    };
    
    return YES;
}

@end
