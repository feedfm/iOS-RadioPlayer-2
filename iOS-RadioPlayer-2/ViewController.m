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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) openPlayer: (id) sender {
    NSLog(@"you clicked open playier!");
    
    UIStoryboard *sb = [FMResources playerStoryboard];
//    UINavigationController *vc = [sb instantiateViewControllerWithIdentifier:@"playerViewController"];
//    FMPlayerViewController *player = (FMPlayerViewController *) vc.topViewController;
    
//    player.title = @"My Radio";

    FMPlayerViewController *player = [sb instantiateViewControllerWithIdentifier:@"playerViewController"];
    player.title = @"My Radio";

    [self presentViewController:player animated:YES completion:nil];
}

@end
