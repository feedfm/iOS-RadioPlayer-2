//
//  FMAdjustImageAlpha.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 6/14/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "UIImage+FMAdjustImageAlpha.h"

@implementation UIImage (FMAdjustImageAlpha)

- (UIImage *)translucentImageWithAlpha:(CGFloat)alpha
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:bounds blendMode:kCGBlendModeScreen alpha:alpha];
    
    UIImage * translucentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return translucentImage;
}

@end
