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
@property (weak, nonatomic) IBOutlet UITextField *token;
@property (weak, nonatomic) IBOutlet UITextField *secret;
@property (weak, nonatomic) IBOutlet UIButton *connect;
@property (weak, nonatomic) IBOutlet UIPickerView *countryPicker;

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
    
   

    sortedCountries  = @[@"Default",@"US",@"MX", @"CA", @"AU", @"GB"];
    _countryPicker.delegate = self; // Also, can be done from IB, if you're using
    _countryPicker.dataSource = self;//
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
//        if ((player.localOfflineStationList.count == 0) &&
//            (player.remoteOfflineStationList.count == 0)) {
//            // just display station collection
//            [self pushStreamingStationCollection:nil];
//        }
        
    } notAvailable:^{
        NSLog(@"not available!");
        
    }];
}

#pragma pickerView


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;// or the number of vertical "columns" the picker will show...
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (sortedCountries!=nil) {
        return [sortedCountries count];//this will tell the picker how many rows it has - in this case, the size of your loaded array...
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    //you can also write code here to descide what data to return depending on the component ("column")
    if (sortedCountries!=nil) {
        return [sortedCountries objectAtIndex:row];//assuming the array contains strings..
    }
    else
    {
        NSLog(@"Register tab empty?");
    }
    return @"empty";//or nil, depending how protective you are
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
        
    switch (row) {
        case 0: // default
            [FMAudioPlayer setStreamingFor:@""];
            break;
        case 1: // US
            [FMAudioPlayer setStreamingFor:@"65.49.22.66"];
            break;
        case 2: // MX
            [FMAudioPlayer setStreamingFor:@"131.178.0.0"];
            break;
        case 3: // CA
            [FMAudioPlayer setStreamingFor:@"100.42.20.0"];
            break;
        case 4: // AU
            [FMAudioPlayer setStreamingFor:@"1.120.0.0"];
            break;
        case 5: // GB
            [FMAudioPlayer setStreamingFor:@"1.186.0.0"];
            break;
        default:
            
            [FMAudioPlayer setStreamingFor:@""];
            break;
    }
}

- (IBAction)secretEditingEnded:(id)sender {
    
    if (self.secret.text.length > 2 && self.token.text.length > 2) {
        [self.connect setEnabled:true];
    } else
    {
        [self.connect setEnabled:true];
    }
}

- (IBAction)changeTokens:(id)sender {
    
    FMAudioPlayer *player = [FMAudioPlayer sharedPlayer];
    [player destroy];
    [FMAudioPlayer setClientToken:self.token.text
                           secret:self.secret.text];
    
    player = [FMAudioPlayer sharedPlayer];
    [player whenAvailable:^{
        NSLog(@"Available!");

        player.secondsOfCrossfade = 0.0;
        [self pushStreamingStationCollection:nil];

    } notAvailable:^{
        NSLog(@"Unavailable!");
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
