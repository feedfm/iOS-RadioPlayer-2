//
//  AppDelegate.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/2/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "AppDelegate.h"
#import <FeedMedia/FeedMedia.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [FMAudioPlayer setClientToken:@"b253e3c9aee06791794c031073967cb16616d9af"
                           secret:@"d3c6f54a458ed2335f54587d02d485d5f46d7b03"];
    
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    [player whenAvailable:^{
        NSLog(@"Available!");
        
        // optionally turn on music crossfading
        player.crossfadeInEnabled = YES;
        player.secondsOfCrossfade = 6.0;
        
    } notAvailable:^{
        NSLog(@"Unavailable!");
    }];
    
    return YES;
}

@end
