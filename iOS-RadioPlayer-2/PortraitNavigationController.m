//
//  PortraitNavigationController.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 8/29/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "PortraitNavigationController.h"

@interface PortraitNavigationController ()

@end

@implementation PortraitNavigationController

- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
