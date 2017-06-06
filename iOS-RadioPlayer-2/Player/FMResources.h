//
//  FMResources.h
//  iOS-RadioPlayer
//
//  Created by Eric Lambrecht on 10/17/16.
//  Copyright © 2016 Eric Lambrecht. All rights reserved.
//

#import "FMPlayerViewController.h"
#import "FMStationCollectionViewController.h"
#import "FMPopUpDownNavigationController.h"
#import <FeedMedia/FeedMedia.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 
 This class exposes static functions that make it easy to display
 the various music player views.
 
 If you just want a music player to be presented on the screen that
 the user can back out of, then use `+ (void) presentPlayerWithTitle:`.
 That method tries to find the frontmost view controller and present
 the music player from there. If you want a different view controller
 to present it, then use the
 `+ (void) presentPlayerFromViewController:WithTitle:` method.
 
 If you want to display the music player within a UINavigationController,
 you can create an instance of the player with one of the
 `+ (void) createPlayerViewController` methods and then push it onto
 the current navigation controller.
 
 The player displays a single station at a time. If you want to display
 a grid of stations, then use the `+ (void) createStationCollectionViewController`
 methods.

 */

@interface FMResources : NSObject

/**
 * This is the key for the URL that is in FMStation.options that points
 * to the station's background image.
 */

@property (class, nonatomic, readonly) NSString *backgroundImageUrlPropertyName;

/**
 * This is the key for the subheader text that is in FMStation.options.
 */

@property (class, nonatomic, readonly) NSString *subheaderPropertyName;

/**
 * This method will create a new FMPlayerViewController and present it on
 * the screen. The code will search for the topmost view controller and
 * present it from there.
 *
 * @param title The title to display for the player
 */

+ (void) presentPlayerWithTitle:(NSString *)title;

/**
 * This method will create a new FMPlayerViewController and present it on
 * the screen. The player will be presented from the provided view controller.
 *
 * @param viewController The view controller to present the player from
 * @param title The title to display for the player
 */
 
+ (void) presentPlayerFromViewController: (UIViewController *) viewController withTitle:(NSString *)title;

/**
 * This method will create a new FMStationCollectionViewController and present it on
 * the screen. The code will search for the topmost view controller and
 * present it from there.
 *
 * @param title The title to display for the station collection screen
 */

+ (void) presentStationCollectionWithTitle:(NSString *)title;

/**
 * This method will create a new FMStationCollectionViewController and present it on
 * the screen. The player will be presented from the provided view controller.
 *
 * @param viewController The view controller to present the station collection view controller from
 * @param title The title to display for the station collection screen
 */

+ (void) presentStationCollectionFromViewController: (UIViewController *) viewController withTitle:(NSString *)title;

/**
 * Create and return a new FMPlayerViewController with the given title. 
 *
 * The view controller expects to be pushed onto a UINavigationController
 *
 * @param title The title to display for the player
 */

+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title;

/**
 * Create and return a new FMPlayerViewController with the given title. Try
 * to find a station with the matching name and display that station when the
 * player is first shown.
 *
 * The view controller expects to be pushed onto a UINavigationController
 *
 * @param title The title to display for the player
 * @param stationName Name of the station to try initially display
 */

+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title showingStationNamed: (NSString *) stationName;

/**
 * Create and return a new FMPlayerViewController with the given title. The player
 * will initially display the provided station. 
 *
 * The view controller expects to be pushed onto a UINavigationController
 *
 * @param title The title to display for the player
 * @param station FMStation that should initially be displayed
 */

+ (FMPlayerViewController *) createPlayerViewControllerWithTitle: (NSString *) title
                                                showingStation: (FMStation *) station;

/**
 * Create and return a new FMStationCollectionViewController with
 * the given title.
 *
 * The view controller expects to be pushed onto a UINavigationController
 *
 * @param title The title to display for the view
 */

+ (FMStationCollectionViewController *) createStationCollectionViewControllerWithTitle: (NSString *) title;

/**
 * Utility function to return a reference to the FMPlayerStoryboard.
 */

+ (UIStoryboard *)playerStoryboard;

/**
 * Utility function to retrieve image assets.
 */

+ (UIImage *)imageNamed:(NSString *)name;

@end
