//
//  CPTThumbsViewController.m
//  PainTracker
//
//  Created by Wendy Kutschke on 4/21/16.
//  Copyright © 2016 Chronic Stimulation, LLC. All rights reserved.
//

#import "CPTThumbsViewController.h"
#import "ReaderDocument.h"
#import "ReaderConstants.h"
#import "ThumbsMainToolbar.h"

@interface CPTThumbsViewController ()

@property (nonatomic, assign) BOOL deviceShaking;

@end


@implementation CPTThumbsViewController


- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Motion Methods

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ([event subtype] == UIEventSubtypeMotionShake) {
        self.deviceShaking = YES;
        DDLogVerbose(@"Shaking has started. %@",[event description]);
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ([event subtype] == UIEventSubtypeMotionShake) {
        self.deviceShaking = NO;
        DDLogVerbose(@"Shaking has ended. %@",[event description]);
        
        // Display Help for view
        [self checkIfHelpFirstViewShouldDisplayForViewKey:kHelpFirstViewKey usingForce:YES];
    }
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if ([event subtype] == UIEventSubtypeMotionShake) {
        self.deviceShaking = NO;
        DDLogVerbose(@"Shaking has cancelled. %@",[event description]);
        
    }
}


@end
