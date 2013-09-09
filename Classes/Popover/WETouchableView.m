//
//  WETouchableView.m
//  WEPopover
//
//  Created by Werner Altewischer on 12/21/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WETouchableView.h"

@interface WETouchableView()

@property (nonatomic) BOOL testingHits;

- (BOOL)isPassthroughView:(UIView *)view;

@end


@implementation WETouchableView

- (UIView *)hitTest:(CGPoint)point
          withEvent:(UIEvent *)event {
	if (self.testingHits) {
		return nil;
	} else if (self.touchForwardingDisabled) {
		return self;
	} else {
		UIView *hitView = [super hitTest:point
                               withEvent:event];
		
		if (hitView == self) {
			//Test whether any of the passthrough views would handle this touch
			self.testingHits = YES;
			UIView *superHitView = [self.superview hitTest:point
                                                 withEvent:event];
			self.testingHits = NO;
			
			if ([self isPassthroughView:superHitView]) {
				hitView = superHitView;
			}
		}
		
		return hitView;
	}
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event {
	[self.delegate viewWasTouched:self];
}


#pragma mark - Private methods

- (BOOL)isPassthroughView:(UIView *)view {
	if (view == nil) {
		return NO;
	}
	
	if ([self.passthroughViews containsObject:view]) {
		return YES;
	}
	
	return [self isPassthroughView:view.superview];
}

@end
