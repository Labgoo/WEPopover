//
//  WEPopoverController.m
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverController.h"
#import "WEPopoverParentView.h"
#import "UIBarButtonItem+WEPopover.h"

#define FADE_DURATION 0.3

@interface WEPopoverController ()

@property(nonatomic) UIPopoverArrowDirection popoverArrowDirection;
@property(nonatomic) BOOL popoverVisible;
@property(nonatomic, weak) UIView *view;
@property(nonatomic, assign) CGSize popoverContentSize;
@property(nonatomic, strong) WETouchableView *backgroundView;

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

    [self dismissPopoverAnimated:NO];

    // First force a load view for the contentViewController so the popoverContentSize is properly initialized
    [self.contentViewController view];

    if (CGSizeEqualToSize(self.popoverContentSize, CGSizeZero)) {
        self.popoverContentSize = self.contentViewController.contentSizeForViewInPopover;
    }

    CGRect displayRect = [self displayRectForView:view];

    WEPopoverContainerViewProperties *properties = self.containerViewProperties ?
            self.containerViewProperties :
            [WEPopoverContainerViewProperties defaultProperties];
    WEPopoverContainerView *containerView = [[WEPopoverContainerView alloc] initWithSize:self.popoverContentSize
                                                                              anchorRect:rect
                                                                             displayRect:displayRect
                                                                permittedArrowDirections:arrowDirections
                                                                              properties:properties];
    self.popoverArrowDirection = containerView.arrowDirection;

    UIView *keyView = self.keyView;

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

    [keyView addSubview:self.backgroundView];

    containerView.frame = [view convertRect:containerView.frame
                                     toView:self.backgroundView];

    [self.backgroundView addSubview:containerView];

    containerView.contentView = self.contentViewController.view;
    containerView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
            UIViewAutoresizingFlexibleRightMargin);

    self.view = containerView;
    [self updateBackgroundPassthroughViews];

    if ([self forwardAppearanceMethods]) {
        [self.contentViewController viewWillAppear:animated];
    }

    [self.view becomeFirstResponder];
    self.popoverVisible = YES;
    if (animated) {
        self.view.alpha = 0.0;

        [UIView animateWithDuration:FADE_DURATION
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.view.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             [self animationDidStop:@"FadeIn"
                                           finished:@(finished)
                                            context:nil];
                         }];

    } else {
        if ([self forwardAppearanceMethods]) {
            [self.contentViewController viewDidAppear:animated];
        }
    }
}

- (void)repositionPopoverFromRect:(CGRect)rect
                           inView:(UIView *)view
         permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                         animated:(BOOL)animated {

    if (animated) {
        [UIView beginAnimations:nil
                        context:nil];
        [UIView setAnimationDuration:FADE_DURATION];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }

    if (CGSizeEqualToSize(self.popoverContentSize, CGSizeZero)) {
        self.popoverContentSize = self.contentViewController.contentSizeForViewInPopover;
    }

    CGRect displayArea = [self displayRectForView:view];
    WEPopoverContainerView *containerView = (WEPopoverContainerView *) self.view;
    [containerView updatePositionWithSize:self.popoverContentSize
                               anchorRect:rect
                              displayRect:displayArea
                 permittedArrowDirections:arrowDirections];

    self.popoverArrowDirection = containerView.arrowDirection;
    containerView.frame = [view convertRect:containerView.frame
                                     toView:self.backgroundView];

    if (animated) {
        [UIView commitAnimations];
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
    if (self.parentView) {
        return self.parentView;
    } else {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        if (window.subviews.count > 0) {
            return window.subviews[0];
        } else {
            return window;
        }
    }
}

- (void)setView:(UIView *)view {
    if (_view != view) {
        _view = view;
    }
}

- (BOOL)forwardAppearanceMethods {
    return ![self.contentViewController respondsToSelector:@selector(shouldAutomaticallyForwardAppearanceMethods)];
}

- (void)updateBackgroundPassthroughViews {
    self.backgroundView.passthroughViews = self.passthroughViews;
}

- (void)animationDidStop:(NSString *)animationID
                finished:(NSNumber *)finished
                 context:(void *)context {

    if ([animationID isEqualToString:@"FadeIn"]) {
        self.view.userInteractionEnabled = YES;
        self.popoverVisible = YES;

        if ([self forwardAppearanceMethods]) {
            [self.contentViewController viewDidAppear:YES];
        }
    } else if ([animationID isEqualToString:@"FadeOut"]) {
        self.popoverVisible = NO;

        if ([self forwardAppearanceMethods]) {
            [self.contentViewController viewDidDisappear:YES];
        }
        [self.view removeFromSuperview];
        self.view = nil;
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;

        BOOL userInitiatedDismissal = [(__bridge NSNumber *) context boolValue];

        if (userInitiatedDismissal) {
            // Only send message to delegate in case the user initiated this event,
            // which is if he touched outside the view
            [self.delegate popoverControllerDidDismissPopover:self];
        }
    }
}

- (void)dismissPopoverAnimated:(BOOL)animated
                 userInitiated:(BOOL)userInitiated {
    if (self.view) {
        if ([self forwardAppearanceMethods]) {
            [self.contentViewController viewWillDisappear:animated];
        }
        self.popoverVisible = NO;
        [self.view resignFirstResponder];

        if (animated) {
            self.view.userInteractionEnabled = NO;

            [UIView animateWithDuration:FADE_DURATION
                                  delay:0.0
                                options:UIViewAnimationOptionCurveLinear
                             animations:^{
                                 self.view.alpha = 0.0;
                             }
                             completion:^(BOOL finished) {
                                 [self animationDidStop:@"FadeOut"
                                               finished:@(finished)
                                                context:(__bridge void *) (@(userInitiated))];
                             }];
        } else {
            if ([self forwardAppearanceMethods]) {
                [self.contentViewController viewDidDisappear:animated];
            }
            [self.view removeFromSuperview];
            self.view = nil;
            [self.backgroundView removeFromSuperview];
            self.backgroundView = nil;
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


@end
