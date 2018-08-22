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
#import "FMDownloadStationsViewController.h"
#import <FeedMedia/FeedMedia.h>

@interface ViewController ()

@property (nonatomic, strong) IBOutlet UIButton *downloadOfflineStations;
@property (nonatomic, strong) IBOutlet UIButton *streamingStations;
@property (nonatomic, strong) IBOutlet UIButton *offlineStations;

@end

@implementation ViewController

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // defaults
    self->_offlineStations.enabled = NO;
    self->_streamingStations.enabled = NO;
    self->_downloadOfflineStations.enabled = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    
    // enable playback of offline stations
    self->_offlineStations.enabled = (player.localOfflineStationList.count > 0);
    
    [player whenAvailable:^{
        // enable streaming stations when streaming music is available
        self->_streamingStations.enabled = YES;
        
        // enable downloading of remote stations
        if (player.remoteOfflineStationList.count > 0) {
            self->_downloadOfflineStations.enabled = YES;
        }
        
        // if no offline stuff, then just display online player
        if ((player.localOfflineStationList.count == 0) &&
            (player.remoteOfflineStationList.count == 0)) {
            // just display station collection
            [self pushStreamingStationCollection:nil];
        }
        
    } notAvailable:^{
        NSLog(@"not available!");
        
    }];
}

- (IBAction) pushStreamingStationCollection: (id) sender {
    FMStationCollectionViewController *stationCollection =
    
    [FMResources createStationCollectionViewControllerWithTitle:@"Streaming Radio" visibleStations:[FMAudioPlayer sharedPlayer].stationList];
    
    [self.navigationController pushViewController:stationCollection animated:YES];
}

- (IBAction) pushOfflineStationCollection: (id) sender {
    FMStationCollectionViewController *stationCollection =
    
    [FMResources createStationCollectionViewControllerWithTitle:@"Offline Radio" visibleStations:[FMAudioPlayer sharedPlayer].localOfflineStationList];
    
    [self.navigationController pushViewController:stationCollection animated:YES];
}

- (IBAction) presentDownloadOfflineStationsViewController {
    UIStoryboard *sb = [FMResources playerStoryboard];
    FMDownloadStationsViewController *dsvc = [sb instantiateViewControllerWithIdentifier:@"downloadStationsViewController"];

    [self.navigationController pushViewController:dsvc animated:YES];
}

@end
