//
//  FMDisclaimerControllerViewController.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/8/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "FMDisclaimerControllerViewController.h"

@interface FMDisclaimerControllerViewController ()

@end

@implementation FMDisclaimerControllerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)closePlayer:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
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
