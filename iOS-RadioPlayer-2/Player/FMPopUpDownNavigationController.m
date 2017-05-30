//
//  FMPopUpDownNavigationController.m
//  iOS-RadioPlayer-2
//
//  Created by Eric Lambrecht on 5/29/17.
//  Copyright © 2017 Feed Media. All rights reserved.
//

#import "FMPopUpDownNavigationController.h"

//
//
//

@interface FMDismissingViewController : UIViewController

@end

@implementation FMDismissingViewController

- (void) viewWillAppear:(BOOL)animated {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

//
//
//

@interface FMIdentityTransitioningAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@end

@implementation FMIdentityTransitioningAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // kill time and do nothing
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * [self transitionDuration:transitionContext]);

    dispatch_after(delay, dispatch_get_main_queue(), ^(void){
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    });
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

@end

@interface FMPopUpDownTransitioningAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL slideDown;

@end

@implementation FMPopUpDownTransitioningAnimator

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (_slideDown) {
        [self animateTransitionDown:transitionContext];
    } else {
        [self animateTransitionUp:transitionContext];
    }
}

- (void)animateTransitionDown:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    [[transitionContext containerView] addSubview:toViewController.view];
    
    toViewController.view.transform = CGAffineTransformMakeTranslation(0, -1 * toViewController.view.frame.size.height);
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toViewController.view.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)animateTransitionUp:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [[transitionContext containerView] addSubview:fromViewController.view];

    fromViewController.view.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromViewController.view.transform =  CGAffineTransformMakeTranslation(0, -1 * fromViewController.view.frame.size.height);
        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

@end


@interface FMPopUpDownNavigationController ()

@end

@implementation FMPopUpDownNavigationController

- (id) init {
    FMDismissingViewController *dvc = [[FMDismissingViewController alloc] init];
    dvc.title = @"";
    
    if (self = [super initWithRootViewController:dvc]) {
        // to disable animation when going 'back' to the root controller
        self.delegate = self;

        // to enable the pop-up down when presenting this
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    
    return self;
}

#pragma mark - <UIViewControllerTransitioningDelegate>


/* The following is what gets the nav controller to animate
 in from the top of the page */
 
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    FMPopUpDownTransitioningAnimator *animator = [[FMPopUpDownTransitioningAnimator alloc] init];
    animator.slideDown = YES;
    
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {

    FMPopUpDownTransitioningAnimator *animator = [[FMPopUpDownTransitioningAnimator alloc] init];
    animator.slideDown = NO;

    return animator;
}

#pragma mark - <UINavigationControllerDelegate>

/* The following makes the 'back' to the root level controller
 not actually do anything while we're dismissing the viewcontroller */
 
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    if (toVC == self.viewControllers[0]) {
        // basically null out the transition to the root view controller,
        // as the controller will be dismissed as soon as the user
        // tries to go 'back' to it
        FMIdentityTransitioningAnimator *itAnimator = [[FMIdentityTransitioningAnimator alloc] init];
        return itAnimator;
        
    } else {
        return nil;
    }
}


@end
