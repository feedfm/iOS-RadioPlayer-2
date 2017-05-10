//
//  FMResources.h
//  iOS-RadioPlayer
//
//  Created by Eric Lambrecht on 10/17/16.
//  Copyright © 2016 Eric Lambrecht. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FMResources : NSObject

@property (class, nonatomic, assign, readonly) NSString *backgroundImageUrlProperty;
@property (class, nonatomic, assign, readonly) NSString *subheaderProperty;

+ (UIStoryboard *)playerStoryboard;
+ (UIImage *)imageNamed:(NSString *)name;

@end
