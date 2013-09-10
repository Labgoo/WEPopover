//
//  WEPopoverContainerView.h
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * This class contains customizable parameter for the containerView
 *
 * Properties for the container view determining the area where the actual content view can/may be displayed.
 * Also images can be supplied for the arrow and background.
 */
@interface WEPopoverContainerViewProperties : NSObject

@property(nonatomic, copy) NSString *backgroundImageName;
@property(nonatomic, copy) NSString *upArrowImageName;
@property(nonatomic, copy) NSString *downArrowImageName;
@property(nonatomic, copy) NSString *leftArrowImageName;
@property(nonatomic, copy) NSString *rightArrowImageName;
@property(nonatomic) CGFloat leftBackgroundMargin;
@property(nonatomic) CGFloat rightBackgroundMargin;
@property(nonatomic) CGFloat topBackgroundMargin;
@property(nonatomic) CGFloat bottomBackgroundMargin;
@property(nonatomic) CGFloat leftContentMargin;
@property(nonatomic) CGFloat rightContentMargin;
@property(nonatomic) CGFloat topContentMargin;
@property(nonatomic) CGFloat bottomContentMargin;
@property(nonatomic) CGFloat topBackgroundCapSize;
@property(nonatomic) CGFloat leftBackgroundCapSize;
@property(nonatomic) CGFloat bottomBackgroundCapSize;
@property(nonatomic) CGFloat rightBackgroundCapSize;
@property(nonatomic) CGFloat arrowMargin;

+ (WEPopoverContainerViewProperties *)defaultProperties;

@end


@class WEPopoverContainerView;

/**
 * This containerView contains arrowImage, backgroundImage and contentView (which should be positioned
 * within backgroundImage's frame)
 */
@interface WEPopoverContainerView : UIView

/**
 * The current arrow direction for the popover.
 */
@property(nonatomic, readonly) UIPopoverArrowDirection arrowDirection;

/**
 * The content view being displayed.
 */
@property(nonatomic, strong) UIView *contentView;

/**
 * Initializes the position of the popover with a size, anchor rect, display area
 * and permitted arrow directions and optionally the properties.
 * If the last is not supplied the defaults are taken (requires images to be present in bundle
 * representing a black rounded background with partial transparency).
 */
- (id)initWithSize:(CGSize)size
        anchorRect:(CGRect)anchorRect
             displayRect:(CGRect)displayRect
permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections
              properties:(WEPopoverContainerViewProperties *)properties;

/**
 * To update the position of the popover with a new anchor rect, display area and permitted arrow directions
 */
- (void)updatePositionWithSize:(CGSize)size
                    anchorRect:(CGRect)anchorRect
                   displayRect:(CGRect)displayRect
      permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections;

@end
