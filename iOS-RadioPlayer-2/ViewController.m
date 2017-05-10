//
//  ViewController.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/2/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "ViewController.h"
#import "FMResources.h"
#import "FMPlayerViewController.h"
#import "FMStationCollectionViewController.h"
#import <FeedMedia/FeedMedia.h>

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UIButton *playerButton;
@property (nonatomic, strong) IBOutlet UIButton *stationCollectionButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[FMAudioPlayer sharedPlayer] whenAvailable:^{
        NSLog(@"stations available!");
        _playerButton.enabled = YES;
        _stationCollectionButton.enabled = YES;
        
    } notAvailable:^{
        NSLog(@"not available!");
        
    }];
}

- (IBAction) openPlayer: (id) sender {
    NSLog(@"you clicked open playier!");
    
    UIStoryboard *sb = [FMResources playerStoryboard];

    FMPlayerViewController *player = [sb instantiateViewControllerWithIdentifier:@"playerViewController"];
    player.title = @"My Radio";

    [self presentViewController:player animated:YES completion:nil];
}

- (IBAction) openStationList: (id) sender {
    NSLog(@"you clicked open station list!");
    
    UIStoryboard *sb = [FMResources playerStoryboard];
    
    FMStationCollectionViewController *stationCollection = [sb instantiateViewControllerWithIdentifier:@"stationCollectionViewController"];
    stationCollection.title = @"My Radio";
    
    [self presentViewController:stationCollection animated:YES completion:nil];
}

@end
