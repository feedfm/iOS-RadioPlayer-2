//
//  FMOfflineStationPickerViewControllerTableViewController.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 8/21/18.
//  Copyright © 2018 Feed Media. All rights reserved.
//

#import "FMDownloadStationsViewController.h"
#import <FeedMedia/FeedMedia.h>
#import <FFCircularProgressView/FFCircularProgressView.h>

@interface FMDownloadStationsViewController () <FMStationDownloadDelegate>

@property (strong, nonatomic) FMAudioPlayer *player;

@end

@implementation FMDownloadStationsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _player = [FMAudioPlayer sharedPlayer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = (NSInteger) _player.remoteOfflineStationList.count;
    
    NSLog(@"returning count of %tu, and %zd", _player.remoteOfflineStationList.count, count);

    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"getting cell at %@", indexPath);

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"remoteStation" forIndexPath:indexPath];

    UILabel *label = (UILabel *) [cell viewWithTag:1];
    FFCircularProgressView *cpv = (FFCircularProgressView *) [cell viewWithTag:2];

    // wire up the FFCircularProgress view so users can tap it
    if (cpv.gestureRecognizers.count == 0) {
        [cpv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downloadButton:)]];
    }
    
    // if we can't find the station, something is really off
    if (indexPath.row >= _player.remoteOfflineStationList.count) {
        label.text = @"Unknown station - ERROR";
        cpv.hidden = YES;
        return cell;
    }

    FMStation *station = (FMStation *) _player.remoteOfflineStationList[indexPath.row];
    label.text = station.name;
    
    cpv.hidden = NO;
    
    FMStation *localStation = [_player localOfflineStationForRemoteOfflineStation:station];
    
    if ((localStation != nil) && [station.identifier isEqual:localStation.identifier]) {
        // station already downloaded
        NSLog(@"already downloaded!");
        cpv.progress = 1.0f;
        
    } else {
        // station can be downloaded/updated
        cpv.progress = 0.0f;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72.0f;
}

/**
 Let users delete contents of a station by swiping left
 */

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                  editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= _player.remoteOfflineStationList.count) {
        return @[ ];
    }
    
    FMStation *station = _player.remoteOfflineStationList[indexPath.row];

    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"delete" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if ([self->_player.activeStation.identifier isEqualToString:station.identifier]) {
            NSLog(@"Can't delete station while it is active");
            return;
        }

        FFCircularProgressView *cpv = [self progressViewForStation:station];
        cpv.progress = 0.0f;

        NSLog(@"deleting offline station %@", station);
        [self->_player deleteOfflineStation:station];
    }];
    
    return @[ action ];
}

/**
 When user hits the download button (well, FFCircularProgressView),
 we try to download that station.
 */

- (IBAction)downloadButton: (id) sender {
    UITapGestureRecognizer *tgr = (UITapGestureRecognizer *) sender;
    FFCircularProgressView *cpv = (FFCircularProgressView *) tgr.view;

    UIView *parent = cpv.superview;
    while (![parent isKindOfClass:UITableViewCell.class]) {
        parent = parent.superview;
    }
    UITableViewCell *cell = (UITableViewCell *) parent;
    
    NSInteger index = [self.tableView indexPathForCell:cell].row;
    FMStation *station = _player.remoteOfflineStationList[index];
    
    if (cpv.progress > 0.0f) {
        // should cancel here.. but can't at the moment
        
    } else {
        // kick off download
        [_player downloadAndSyncStation:station withDelegate:self];
    }
}

/**
 Map an FMStation to the FFCircularProgressView that is representing its
 download state
 */

- (FFCircularProgressView *) progressViewForStation: (FMStation *) station {
    NSUInteger index = [_player.remoteOfflineStationList indexOfObject:station];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    if (cell) {
        return (FFCircularProgressView *) [cell viewWithTag:2];
    }

    return nil;
}

/**
 FMStationDownloadDelegate method - not really needed here.
 */

- (void)stationDownloadComplete:(FMStation *)station {
    FFCircularProgressView *downloadButton = [self progressViewForStation:station];

    if (downloadButton) {
        downloadButton.progress = 1.0f;
    }
}

/**
 As we download a station, update the download indicator for it
 */

- (void)stationDownloadProgress:(FMStation *)station pendingCount:(int)pendingCount failedCount:(int)failedCount totalCount:(int)totalCount {
    FFCircularProgressView *downloadButton = [self progressViewForStation:station];

    if (downloadButton) {
        if (totalCount == 0) {
            [downloadButton stopSpinProgressBackgroundLayer];
            downloadButton.progress = 1.0f;

        } else {
            float progress = (float) (totalCount - pendingCount) / (float) totalCount;

            if (progress < 0.1f) {
                downloadButton.progress = 0.0f;
                [downloadButton startSpinProgressBackgroundLayer];

            } else {
                [downloadButton stopSpinProgressBackgroundLayer];
                downloadButton.progress = progress;
            }
        }
    }
    
}

@end
