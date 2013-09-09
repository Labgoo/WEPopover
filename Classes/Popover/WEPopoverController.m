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

@interface WEPopoverController()

@property (nonatomic) UIPopoverArrowDirection popoverArrowDirection;
@property (nonatomic) BOOL popoverVisible;
@property (nonatomic, weak) UIView *view;
@property (nonatomic, assign) CGSize popoverContentSize;
@property (nonatomic, strong) id <NSObject> context;
@property (nonatomic, weak) UIView *parentView;
@property (nonatomic, strong) WETouchableView *backgroundView;



- (UIView *)keyView;
- (void)updateBackgroundPassthroughViews;
- (void)setView:(UIView *)v;
- (CGRect)displayAreaForView:(UIView *)theView;
- (WEPopoverContainerViewProperties *)defaultContainerViewProperties;
- (void)dismissPopoverAnimated:(BOOL)animated userInitiated:(BOOL)userInitiated;

@end


@implementation WEPopoverController

#pragma mark - Inits, Getters & Setters

- (id)init {
    self = [super init];
	if (self) {
	}
	return self;
}

- (id)initWithContentViewController:(UIViewController *)viewController {
    self = [self init];
	if (self) {
		self.contentViewController = viewController;
	}
	return self;
}

- (BOOL)isPopoverVisible {
    if (!_popoverVisible) {
        return NO;
    }

    UIView *sv = self.view;
    BOOL foundWindowAsSuperView = NO;
    while ((sv = sv.superview) != nil) {
        if ([sv isKindOfClass:[UIWindow class]]) {
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
- (void)setPassthroughViews:(NSArray *)array {
    _passthroughViews = nil;
    if (array) {
        _passthroughViews = [[NSArray alloc] initWithArray:array];
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

- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item 
			   permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
							   animated:(BOOL)animated {
	
	UIView *v = [self keyView];
	CGRect rect = [item frameInView:v];
	
	return [self presentPopoverFromRect:rect inView:v permittedArrowDirections:arrowDirections animated:animated];
}

- (void)repositionPopoverFromRect:(CGRect)rect
                           inView:(UIView *)theView
         permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections {

    [self repositionPopoverFromRect:rect
                             inView:theView
           permittedArrowDirections:arrowDirections
                           animated:NO];
}

- (void)presentPopoverFromRect:(CGRect)rect 
						inView:(UIView *)theView 
	  permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections 
					  animated:(BOOL)animated {

	[self dismissPopoverAnimated:NO];
	
	//First force a load view for the contentViewController so the popoverContentSize is properly initialized
	[self.contentViewController view];
	
	if (CGSizeEqualToSize(self.popoverContentSize, CGSizeZero)) {
		self.popoverContentSize = self.contentViewController.contentSizeForViewInPopover;
	}
	
	CGRect displayArea = [self displayAreaForView:theView];
	
	WEPopoverContainerViewProperties *properties = self.containerViewProperties ?
            self.containerViewProperties :
            [self defaultContainerViewProperties];
	WEPopoverContainerView *containerView = [[WEPopoverContainerView alloc] initWithSize:self.popoverContentSize
                                                                              anchorRect:rect
                                                                             displayArea:displayArea
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
	
	containerView.frame = [theView convertRect:containerView.frame
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
                            options:UIViewAnimationCurveLinear
                         animations:^{
                             
                             self.view.alpha = 1.0;
                             
                         } completion:^(BOOL finished) {
                             
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
						   inView:(UIView *)theView
		 permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                         animated:(BOOL)animated {
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:FADE_DURATION];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }
    
    if (CGSizeEqualToSize(self.popoverContentSize, CGSizeZero)) {
		self.popoverContentSize = self.contentViewController.contentSizeForViewInPopover;
	}
	
	CGRect displayArea = [self displayAreaForView:theView];
	WEPopoverContainerView *containerView = (WEPopoverContainerView *)self.view;
	[containerView updatePositionWithSize:self.popoverContentSize
                               anchorRect:rect
									displayArea:displayArea
					   permittedArrowDirections:arrowDirections];
	
	self.popoverArrowDirection = containerView.arrowDirection;
	containerView.frame = [theView convertRect:containerView.frame
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

- (void)setView:(UIView *)v {
	if (_view != v) {
		_view = v;
	}
}

- (BOOL)forwardAppearanceMethods {
    return ![self.contentViewController respondsToSelector:@selector(automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers)];
}

- (void)updateBackgroundPassthroughViews {
	self.backgroundView.passthroughViews = self.passthroughViews;
}

- (void)animationDidStop:(NSString *)animationID
                finished:(NSNumber *)finished
                 context:(void *)theContext {

    if ([animationID isEqual:@"FadeIn"]) {
        self.view.userInteractionEnabled = YES;
        self.popoverVisible = YES;

        if ([self forwardAppearanceMethods]) {
            [self.contentViewController viewDidAppear:YES];
        }
    } else if ([animationID isEqual:@"FadeOut"]) {
        self.popoverVisible = NO;

        if ([self forwardAppearanceMethods]) {
            [self.contentViewController viewDidDisappear:YES];
        }
        [self.view removeFromSuperview];
        self.view = nil;
        [self.backgroundView removeFromSuperview];
        self.backgroundView = nil;

        BOOL userInitiatedDismissal = [(__bridge NSNumber *)theContext boolValue];

        if (userInitiatedDismissal) {
            //Only send message to delegate in case the user initiated this event, which is if he touched outside the view
            [self.delegate popoverControllerDidDismissPopover:self];
        }
    }
}

- (void)dismissPopoverAnimated:(BOOL)animated userInitiated:(BOOL)userInitiated {
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
                                options:UIViewAnimationCurveLinear
                             animations:^{
                                 
                                 self.view.alpha = 0.0;
                                 
                             } completion:^(BOOL finished) {
                                 
                                 [self animationDidStop:@"FadeOut" finished:@(finished) context:(__bridge void *)(@(userInitiated))];
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

- (CGRect)displayAreaForView:(UIView *)theView {
	CGRect displayArea = CGRectZero;
	if ([theView conformsToProtocol:@protocol(WEPopoverParentView)] && [theView respondsToSelector:@selector(displayAreaForPopover)]) {
		displayArea = [(id <WEPopoverParentView>)theView displayAreaForPopover];
	} else {
        UIView *keyView = [self keyView];
		displayArea = [keyView convertRect:keyView.bounds toView:theView];
	}
	return displayArea;
}

//Enable to use the simple popover style
- (WEPopoverContainerViewProperties *)defaultContainerViewProperties {
	WEPopoverContainerViewProperties *ret = [WEPopoverContainerViewProperties new];
	
	CGSize imageSize = CGSizeMake(30.0f, 30.0f);
	NSString *bgImageName = @"popoverBgSimple.png";
	CGFloat bgMargin = 6.0;
	CGFloat contentMargin = 2.0;
	
	ret.leftBackgroundMargin = bgMargin;
	ret.rightBackgroundMargin = bgMargin;
	ret.topBackgroundMargin = bgMargin;
	ret.bottomBackgroundMargin = bgMargin;
	ret.leftBackgroundCapSize = imageSize.width/2;
	ret.topBackgroundCapSize = imageSize.height/2;
	ret.backgroundImageName = bgImageName;
	ret.leftContentMargin = contentMargin;
	ret.rightContentMargin = contentMargin;
	ret.topContentMargin = contentMargin;
	ret.bottomContentMargin = contentMargin;
	ret.arrowMargin = 1.0;
	
	ret.upArrowImageName = @"popoverArrowUpSimple.png";
	ret.downArrowImageName = @"popoverArrowDownSimple.png";
	ret.leftArrowImageName = @"popoverArrowLeftSimple.png";
	ret.rightArrowImageName = @"popoverArrowRightSimple.png";
	return ret;
}

@end
