//
//  FMAdjustImageAlpha.h
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 6/14/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FMAdjustImageAlpha)

- (UIImage *)translucentImageWithAlpha:(CGFloat)alpha;

@end
