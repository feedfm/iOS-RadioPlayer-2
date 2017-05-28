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
    
    //FMLogSetLevel(FMLogLevelDebug);
    
    [[FMAudioPlayer sharedPlayer] whenAvailable:^{
        NSLog(@"stations available!");
        _playerButton.enabled = YES;
        _stationCollectionButton.enabled = YES;
        
    } notAvailable:^{
        NSLog(@"not available!");
        
    }];
}

- (IBAction) openPlayer: (id) sender {
    FMPlayerViewController *player = [FMResources createPlayerViewControllerWithTitle:@"My Radio"];

    [self.navigationController pushViewController:player animated:YES];
}

- (IBAction) openStationList: (id) sender {
    FMStationCollectionViewController *stationCollection =
    
    [FMResources createStationCollectionViewControllerWithTitle:@"My Radio"];
    
    [self.navigationController pushViewController:stationCollection animated:YES];
}

- (IBAction) openPlayerOnStationTwo: (id) sender {
    FMPlayerViewController *player = [FMResources createPlayerViewControllerWithTitle:@"My Radio" showingStationNamed:@"Station Two"];
    
    [self.navigationController pushViewController:player animated:YES];
}

- (IBAction) presentViewController {
    [FMResources presentPlayerFromViewController: self withTitle:@"music!"];
}

@end
