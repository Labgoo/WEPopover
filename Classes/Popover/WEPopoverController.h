//
//  WEPopoverController.h
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WEPopoverContainerView.h"
#import "WETouchableView.h"

@class WEPopoverController;

@protocol WEPopoverControllerDelegate <NSObject>

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController;
- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController;

@end

/**
 * Popover controller for the iPhone, mimicking the iPad UIPopoverController interface.
 * See that class for more details.
 */
@interface WEPopoverController : NSObject <WETouchableViewDelegate>

@property(nonatomic, strong) UIViewController *contentViewController;
@property(nonatomic, strong) WEPopoverContainerViewProperties *containerViewProperties;
@property(nonatomic, readonly, getter=isPopoverVisible) BOOL popoverVisible;
@property(nonatomic, readonly) UIPopoverArrowDirection popoverArrowDirection;
@property(nonatomic, weak) id <WEPopoverControllerDelegate> delegate;
@property(nonatomic, copy) NSArray *passthroughViews;
@property(nonatomic, strong) UIView *view;


- (id)initWithContentViewController:(UIViewController *)contentViewController;

- (void)dismissPopoverAnimated:(BOOL)animated;

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)barButtonItem
               permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                               animated:(BOOL)animated;

- (void)presentPopoverFromRect:(CGRect)rect
                        inView:(UIView *)view
      permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                      animated:(BOOL)animated;

- (void)presentPopoverFromRect:(CGRect)rect
                        inView:(UIView *)view
       permittedArrowDirection:(UIPopoverArrowDirection)arrowDirection
           appearingAnimations:(void (^)(void))appearingAnimations
         disapperaingAnimation:(void (^)(void))disappearingAnimations;

@end
