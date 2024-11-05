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

        // By default, the player sets the `AVAudioSessionCategoryOptions` to `AVAudioSessionCategoryOptionMixWithOthers`, which
        // prevents us from becoming the 'Now Playing' app in the lock screen. The following removes that option, so this
        // app will show up and be controllable on the lock screen.
        [player setAVAudioSessionCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:  0 ];

        player.secondsOfCrossfade = 0.0;

    } notAvailable:^{
        NSLog(@"Unavailable!");
    }];
    
    return YES;
}

@end
