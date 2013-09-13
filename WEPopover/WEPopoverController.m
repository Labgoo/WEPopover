//
//  WEPopoverController.m
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <QuartzCore/CATransaction.h>
#import "WEPopoverController.h"
#import "WEPopoverParentView.h"
#import "UIBarButtonItem+WEPopover.h"

typedef void (^Animations)(void);

const CGFloat kFadeDuration = 0.3;

@interface WEPopoverController ()

@property(nonatomic) UIPopoverArrowDirection popoverArrowDirection;
@property(nonatomic) BOOL popoverVisible;
@property(nonatomic) CGSize popoverContentSize;
@property(nonatomic, strong) UIView *view;
@property(nonatomic, strong) WETouchableView *backgroundView;
@property(nonatomic, strong) Animations appearingAnimations;
@property(nonatomic, strong) Animations disappearingAnimations;

@end


@implementation WEPopoverController

#pragma mark - Inits, Getters & Setters

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)initWithContentViewController:(UIViewController *)contentViewController {
    self = [self init];
    if (self) {
        self.contentViewController = contentViewController;
        self.arrowOffset = 0.0;
    }
    return self;
}

- (BOOL)isPopoverVisible {
    if (!_popoverVisible) {
        return NO;
    }

    UIView *superView = self.view;
    BOOL foundWindowAsSuperView = NO;
    while ((superView = superView.superview) != nil) {
        if ([superView isKindOfClass:[UIWindow class]]) {
            foundWindowAsSuperView = YES;
            break;
        }
    }
    return foundWindowAsSuperView;
}

- (void)setContentViewController:(UIViewController *)viewController {
    if (viewController != _contentViewController) {
        _contentViewController = viewController;
        _popoverContentSize = CGSizeZero;
    }
}

- (void)setView:(UIView *)view {
    if (_view != view) {
        _view = view;
    }
}

// Overridden setter to copy the passthroughViews to the background view if it exists already
- (void)setPassthroughViews:(NSArray *)views {
    _passthroughViews = nil;
    if (views) {
        _passthroughViews = [[NSArray alloc] initWithArray:views];
    }
    [self updateBackgroundPassthroughViews];
}

- (void)dealloc {
    [self dismissPopoverAnimated:NO];
}

#pragma mark - Public APIs

- (void)dismissPopoverAnimated:(BOOL)animated {
    [self dismissPopoverAnimated:animated
                   userInitiated:NO];
}

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)barButtonItem
               permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                               animated:(BOOL)animated {

    UIView *view = [self keyView];
    CGRect rect = [barButtonItem frameInView:view];

    return [self presentPopoverFromRect:rect
                                 inView:view
               permittedArrowDirections:arrowDirections
                               animated:animated];
}

- (void)presentPopoverFromRect:(CGRect)rect
                        inView:(UIView *)view
      permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                      animated:(BOOL)animated {
    Animations appearingAnimations = nil;
    Animations disappearingAnimations = nil;

    if (animated) {
        appearingAnimations = ^(void) {
            self.view.alpha = 0.0;

            [UIView animateWithDuration:kFadeDuration
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 self.view.alpha = 1.0;
                             }
                             completion:^(BOOL finished) {
                             }];
        };

        disappearingAnimations = ^(void) {
            self.view.userInteractionEnabled = NO;

            [UIView animateWithDuration:kFadeDuration
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 self.view.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                             }];
        };
    }

    [self presentPopoverFromRect:rect
                          inView:view
        permittedArrowDirections:arrowDirections
             appearingAnimations:appearingAnimations
          disappearingAnimations:disappearingAnimations];
}

- (void)presentPopoverFromRect:(CGRect)rect
                        inView:(UIView *)view
      permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
           appearingAnimations:(void (^)(void))appearingAnimations
        disappearingAnimations:(void (^)(void))disappearingAnimations {
    self.appearingAnimations = appearingAnimations;
    self.disappearingAnimations = disappearingAnimations;
    [self dismissPopoverAnimated:NO];

    // First force a load view for the contentViewController so the popoverContentSize is properly initialized
    [self.contentViewController view];

    if (CGSizeEqualToSize(self.popoverContentSize, CGSizeZero)) {
        self.popoverContentSize = self.contentViewController.contentSizeForViewInPopover;
    }

    UIView *keyView = self.keyView;
    CGRect displayRect = [self displayRectForView:view];

    WEPopoverContainerViewProperties *properties = self.containerViewProperties ?
            self.containerViewProperties :
            [WEPopoverContainerViewProperties defaultProperties];
    WEPopoverContainerView *containerView = [[WEPopoverContainerView alloc] initWithSize:self.popoverContentSize
                                                                              anchorRect:rect
                                                                             displayRect:displayRect
                                                               arrowOffsetFromBackground:self.arrowOffset
                                                                permittedArrowDirections:arrowDirections
                                                                              properties:properties];
    self.popoverArrowDirection = containerView.arrowDirection;


    self.backgroundView = [[WETouchableView alloc] initWithFrame:keyView.bounds];
    self.backgroundView.contentMode = UIViewContentModeScaleToFill;
    self.backgroundView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
            UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleRightMargin |
            UIViewAutoresizingFlexibleTopMargin |
            UIViewAutoresizingFlexibleHeight |
            UIViewAutoresizingFlexibleBottomMargin);
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.backgroundView.delegate = self;
    [self.backgroundView addSubview:containerView];

    [keyView addSubview:self.backgroundView];
    containerView.frame = [view convertRect:containerView.frame
                                     toView:self.backgroundView];
    containerView.contentView = self.contentViewController.view;
    containerView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
            UIViewAutoresizingFlexibleRightMargin);

    self.view = containerView;
    [self updateBackgroundPassthroughViews];

    if ([self forwardAppearanceMethods]) {
        [self.contentViewController viewWillAppear:(appearingAnimations ? YES : NO)];
    }

    [self.view becomeFirstResponder];

    if (appearingAnimations) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self cleanUpAfterAppearing:YES];
        }];
        appearingAnimations();
        [CATransaction commit];
    } else {
        [self cleanUpAfterAppearing:NO];
    }
}

#pragma mark - WETouchableViewDelegate

- (void)viewWasTouched:(WETouchableView *)view {
    if (self.isPopoverVisible) {
        if (!self.delegate || [self.delegate popoverControllerShouldDismissPopover:self]) {
            [self dismissPopoverAnimated:YES
                           userInitiated:YES];
        }
    }
}

#pragma mark - Private methods

- (UIView *)keyView {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.subviews.count > 0) {
        return window.subviews[0];
    } else {
        return window;
    }
}

- (BOOL)forwardAppearanceMethods {
    return ![self.contentViewController respondsToSelector:@selector(shouldAutomaticallyForwardAppearanceMethods)];
}

- (void)updateBackgroundPassthroughViews {
    self.backgroundView.passthroughViews = self.passthroughViews;
}

- (void)dismissPopoverAnimated:(BOOL)animated
                 userInitiated:(BOOL)userInitiated {
    if (self.view) {
        if ([self forwardAppearanceMethods]) {
            [self.contentViewController viewWillDisappear:animated];
        }
        [self.view resignFirstResponder];

        if (animated) {
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [self cleanUpAfterDisappearing:YES];
                if (userInitiated) {
                    // Only send message to delegate in case the user initiated this event,
                    // which is if he touched outside the view
                    [self.delegate popoverControllerDidDismissPopover:self];
                }
            }];
            if (self.disappearingAnimations) {
                self.disappearingAnimations();
            }
            [CATransaction commit];
        } else {
            [self cleanUpAfterDisappearing:NO];
        }
    }
}

- (CGRect)displayRectForView:(UIView *)view {
    CGRect displayRect;
    if ([view conformsToProtocol:@protocol(WEPopoverParentView)]
            && [view respondsToSelector:@selector(displayRectForPopover)]) {
        displayRect = [(id <WEPopoverParentView>) view displayRectForPopover];
    } else {
        UIView *keyView = [self keyView];
        displayRect = [keyView convertRect:keyView.bounds
                                    toView:view];
    }
    return displayRect;
}

- (void)cleanUpAfterAppearing:(BOOL)animated {
    self.view.userInteractionEnabled = YES;
    self.popoverVisible = YES;

    if ([self forwardAppearanceMethods]) {
        [self.contentViewController viewDidAppear:animated];
    }
}

- (void)cleanUpAfterDisappearing:(BOOL)animated {
    self.popoverVisible = NO;

    if ([self forwardAppearanceMethods]) {
        [self.contentViewController viewDidDisappear:animated];
    }
    [self.view removeFromSuperview];
    self.view = nil;
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
}

@end
