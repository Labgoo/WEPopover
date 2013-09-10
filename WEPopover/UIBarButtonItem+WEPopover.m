/*
 *  UIBarButtonItem+WEPopover.m
 *  WEPopover
 *
 *  Created by Werner Altewischer on 07/05/11.
 *  Copyright 2010 Werner IT Consultancy. All rights reserved.
 *
 */

#import "UIBarButtonItem+WEPopover.h" 

@implementation UIBarButtonItem(WEPopover)

- (CGRect)frameInView:(UIView *)view {
	
	UIView *theView = self.customView;
	if (!theView && [self respondsToSelector:@selector(view)]) {
		theView = [self performSelector:@selector(view)];
	}
	
	UIView *parentView = theView.superview;
	NSArray *subviews = parentView.subviews;
	
	NSUInteger indexOfView = [subviews indexOfObject:theView];
	NSUInteger subviewCount = subviews.count;
	
	if (subviewCount > 0 && indexOfView != NSNotFound) {
		UIView *button = parentView.subviews[indexOfView];
		return [button convertRect:button.bounds
                            toView:view];
	} else {
		return CGRectZero;
	}
}

- (UIView *)superview {
	UIView *theView = self.customView;
	if (!theView && [self respondsToSelector:@selector(view)]) {
		theView = [self performSelector:@selector(view)];
	}
	
	UIView *parentView = theView.superview;
	return parentView;
}

@end