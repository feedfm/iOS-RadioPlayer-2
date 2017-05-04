//
//  FMPlayerScreen.h
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/4/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FeedMedia/FeedMedia.h>
#import <FeedMEdia/FeedMediaUI.h>
#import <OAStackView/OAStackView.h>

@interface FMPlayerScreen : OAStackView

@property (strong, nonatomic) FMMetadataLabel *trackLineOne;
@property (strong, nonatomic) FMMetadataLabel *trackLineTwo;
@property (strong, nonatomic) MarqueeLabel *noticeLine;

@property (strong, nonatomic) NSString *trackLineOneFormat;
@property (strong, nonatomic) NSString *trackLineTwoFormat;
@property (strong, nonatomic) NSString *callToAction;

@end
