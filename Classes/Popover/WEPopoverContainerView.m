//
//  WEPopoverContainerViewProperties.m
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverContainerView.h"

@implementation WEPopoverContainerViewProperties

@end


@interface WEPopoverContainerView()

@property(nonatomic) UIPopoverArrowDirection arrowDirection;
@property(nonatomic, strong) UIImage *backgroundImage;
@property(nonatomic, strong) UIImage *arrowImage;
@property(nonatomic, strong) WEPopoverContainerViewProperties *properties;

@property(nonatomic) CGRect backgroundRect;
@property(nonatomic) CGRect arrowRect;
@property(nonatomic) CGPoint offset;
@property(nonatomic) CGPoint arrowOffset;
@property(nonatomic) CGSize correctedSize;


- (void)determineGeometryForSize:(CGSize)theSize
                      anchorRect:(CGRect)anchorRect
                     displayArea:(CGRect)displayArea
        permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections;
- (CGRect)contentRect;
- (CGSize)contentSize;
- (void)setProperties:(WEPopoverContainerViewProperties *)properties;
- (void)initFrame;

@end

@implementation WEPopoverContainerView

- (id)initWithSize:(CGSize)theSize
		anchorRect:(CGRect)anchorRect 
	   displayArea:(CGRect)displayArea
permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections
		properties:(WEPopoverContainerViewProperties *)theProperties {
	if ((self = [super initWithFrame:CGRectZero])) {
		
		[self setProperties:theProperties];
		self.correctedSize = CGSizeMake(theSize.width + self.properties.leftBackgroundMargin + self.properties.rightBackgroundMargin + self.properties.leftContentMargin + self.properties.rightContentMargin,
								   theSize.height + self.properties.topBackgroundMargin + self.properties.bottomBackgroundMargin + self.properties.topContentMargin + self.properties.bottomContentMargin);
		[self determineGeometryForSize:self.correctedSize anchorRect:anchorRect displayArea:displayArea permittedArrowDirections:permittedArrowDirections];
		[self initFrame];
		self.backgroundColor = [UIColor clearColor];
		UIImage *theImage = [UIImage imageNamed:self.properties.backgroundImageName];
		self.backgroundImage = [theImage stretchableImageWithLeftCapWidth:self.properties.leftBackgroundCapSize topCapHeight:self.properties.topBackgroundCapSize];
		
		self.clipsToBounds = YES;
		self.userInteractionEnabled = YES;
	}
	return self;
}


- (void)drawRect:(CGRect)rect {
	[self.backgroundImage drawInRect:self.backgroundRect
                           blendMode:kCGBlendModeNormal
                               alpha:1.0];
	[self.arrowImage drawInRect:self.arrowRect
                      blendMode:kCGBlendModeNormal
                          alpha:1.0];
}

- (void)updatePositionWithSize:(CGSize)theSize
                    anchorRect:(CGRect)anchorRect
                   displayArea:(CGRect)displayArea
      permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections {

    self.correctedSize = CGSizeMake(theSize.width + self.properties.leftBackgroundMargin + self.properties.rightBackgroundMargin + self.properties.leftContentMargin + self.properties.rightContentMargin,
                               theSize.height + self.properties.topBackgroundMargin + self.properties.bottomBackgroundMargin + self.properties.topContentMargin + self.properties.bottomContentMargin);
	[self determineGeometryForSize:self.correctedSize
                        anchorRect:anchorRect
                       displayArea:displayArea
          permittedArrowDirections:permittedArrowDirections];
	[self initFrame];
    [self setNeedsDisplay];
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	return CGRectContainsPoint(self.contentRect, point);	
} 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
}

- (void)setContentView:(UIView *)view {
	if (view != _contentView) {
		_contentView = view;
		_contentView.frame = self.contentRect;
		[self addSubview:_contentView];
	}
}



#pragma mark - Private methods

- (void)initFrame {
	CGRect theFrame = CGRectOffset(CGRectUnion(self.backgroundRect, self.arrowRect), self.offset.x, self.offset.y);
	
	//If arrow rect origin is < 0 the frame above is extended to include it so we should offset the other rects
    self.arrowOffset = CGPointMake(MAX(0, -self.arrowRect.origin.x), MAX(0, -self.arrowRect.origin.y));
	self.backgroundRect = CGRectOffset(self.backgroundRect, self.arrowOffset.x, self.arrowOffset.y);
    self.arrowRect = CGRectOffset(self.arrowRect, self.arrowOffset.x, self.arrowOffset.y);
	    
    self.frame = CGRectIntegral(theFrame);
}																		 

- (CGSize)contentSize {
	return self.contentRect.size;
}

- (CGRect)contentRect {
	CGRect rect = CGRectMake(self.properties.leftBackgroundMargin + self.properties.leftContentMargin + self.arrowOffset.x,
							 self.properties.topBackgroundMargin + self.properties.topContentMargin + self.arrowOffset.y,
							 self.backgroundRect.size.width - self.properties.leftBackgroundMargin - self.properties.rightBackgroundMargin - self.properties.leftContentMargin - self.properties.rightContentMargin,
							 self.backgroundRect.size.height - self.properties.topBackgroundMargin - self.properties.bottomBackgroundMargin - self.properties.topContentMargin - self.properties.bottomContentMargin);
	return rect;
}

- (void)setProperties:(WEPopoverContainerViewProperties *)properties {
	if (_properties != properties) {
		_properties = properties;
	}
}

- (void)determineGeometryForSize:(CGSize)theSize anchorRect:(CGRect)anchorRect displayArea:(CGRect)displayArea permittedArrowDirections:(UIPopoverArrowDirection)supportedArrowDirections {	
	
	//Determine the frame, it should not go outside the display area
	UIPopoverArrowDirection theArrowDirection = UIPopoverArrowDirectionUp;
	
	self.offset =  CGPointZero;
	self.backgroundRect = CGRectZero;
	self.arrowRect = CGRectZero;
	self.arrowDirection = UIPopoverArrowDirectionUnknown;
	
	CGFloat biggestSurface = 0.0f;
	CGFloat currentMinMargin = 0.0f;
	
	UIImage *upArrowImage = [UIImage imageNamed:self.properties.upArrowImageName];
	UIImage *downArrowImage = [UIImage imageNamed:self.properties.downArrowImageName];
	UIImage *leftArrowImage = [UIImage imageNamed:self.properties.leftArrowImageName];
	UIImage *rightArrowImage = [UIImage imageNamed:self.properties.rightArrowImageName];
	
	while (theArrowDirection <= UIPopoverArrowDirectionRight) {
		
		if ((supportedArrowDirections & theArrowDirection)) {
			
			CGRect theBgRect = CGRectMake(0, 0, theSize.width, theSize.height);
			CGRect theArrowRect = CGRectZero;
			CGPoint theOffset = CGPointZero;
			CGFloat xArrowOffset = 0.0;
			CGFloat yArrowOffset = 0.0;
			CGPoint anchorPoint = CGPointZero;
			
			switch (theArrowDirection) {
				case UIPopoverArrowDirectionUp:
					
					anchorPoint = CGPointMake(CGRectGetMidX(anchorRect) - displayArea.origin.x, CGRectGetMaxY(anchorRect) - displayArea.origin.y);
                    
                	xArrowOffset = theSize.width / 2 - upArrowImage.size.width / 2;
					yArrowOffset = self.properties.topBackgroundMargin - upArrowImage.size.height;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - upArrowImage.size.width / 2, anchorPoint.y  - yArrowOffset);
					
					if (theOffset.x < 0) {
						xArrowOffset += theOffset.x;
						theOffset.x = 0;
					} else if (theOffset.x + theSize.width > displayArea.size.width) {
						xArrowOffset += (theOffset.x + theSize.width - displayArea.size.width);
						theOffset.x = displayArea.size.width - theSize.width;
					}
					
					//Cap the arrow offset
					xArrowOffset = MAX(xArrowOffset, self.properties.leftBackgroundMargin + self.properties.arrowMargin);
					xArrowOffset = MIN(xArrowOffset, theSize.width - self.properties.rightBackgroundMargin - self.properties.arrowMargin - upArrowImage.size.width);
					
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, upArrowImage.size.width, upArrowImage.size.height);
					
					break;
				case UIPopoverArrowDirectionDown:
					
					anchorPoint = CGPointMake(CGRectGetMidX(anchorRect)  - displayArea.origin.x, CGRectGetMinY(anchorRect) - displayArea.origin.y);
					
					xArrowOffset = theSize.width / 2 - downArrowImage.size.width / 2;
					yArrowOffset = theSize.height - self.properties.bottomBackgroundMargin;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - downArrowImage.size.width / 2, anchorPoint.y - yArrowOffset - downArrowImage.size.height);
					
					if (theOffset.x < 0) {
						xArrowOffset += theOffset.x;
						theOffset.x = 0;
					} else if (theOffset.x + theSize.width > displayArea.size.width) {
						xArrowOffset += (theOffset.x + theSize.width - displayArea.size.width);
						theOffset.x = displayArea.size.width - theSize.width;
					}
					
					//Cap the arrow offset
					xArrowOffset = MAX(xArrowOffset, self.properties.leftBackgroundMargin + self.properties.arrowMargin);
					xArrowOffset = MIN(xArrowOffset, theSize.width - self.properties.rightBackgroundMargin - self.properties.arrowMargin - downArrowImage.size.width);
					
					theArrowRect = CGRectMake(xArrowOffset , yArrowOffset, downArrowImage.size.width, downArrowImage.size.height);
					
					break;
				case UIPopoverArrowDirectionLeft:
					
					anchorPoint = CGPointMake(CGRectGetMaxX(anchorRect) - displayArea.origin.x, CGRectGetMidY(anchorRect) - displayArea.origin.y);
					
					xArrowOffset = self.properties.leftBackgroundMargin - leftArrowImage.size.width;
					yArrowOffset = theSize.height / 2  - leftArrowImage.size.height / 2;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset, anchorPoint.y - yArrowOffset - leftArrowImage.size.height / 2);
					
					if (theOffset.y < 0) {
						yArrowOffset += theOffset.y;
						theOffset.y = 0;
					} else if (theOffset.y + theSize.height > displayArea.size.height) {
						yArrowOffset += (theOffset.y + theSize.height - displayArea.size.height);
						theOffset.y = displayArea.size.height - theSize.height;
					}
					
					//Cap the arrow offset
					yArrowOffset = MAX(yArrowOffset, self.properties.topBackgroundMargin + self.properties.arrowMargin);
					yArrowOffset = MIN(yArrowOffset, theSize.height - self.properties.bottomBackgroundMargin - self.properties.arrowMargin - leftArrowImage.size.height);
					
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, leftArrowImage.size.width, leftArrowImage.size.height);
					
					break;
				case UIPopoverArrowDirectionRight:
					
					anchorPoint = CGPointMake(CGRectGetMinX(anchorRect) - displayArea.origin.x, CGRectGetMidY(anchorRect) - displayArea.origin.y);
					
					xArrowOffset = theSize.width - self.properties.rightBackgroundMargin;
					yArrowOffset = theSize.height / 2  - rightArrowImage.size.width / 2;
					
					theOffset = CGPointMake(anchorPoint.x - xArrowOffset - rightArrowImage.size.width, anchorPoint.y - yArrowOffset - rightArrowImage.size.height / 2);
					
					if (theOffset.y < 0) {
						yArrowOffset += theOffset.y;
						theOffset.y = 0;
					} else if (theOffset.y + theSize.height > displayArea.size.height) {
						yArrowOffset += (theOffset.y + theSize.height - displayArea.size.height);
						theOffset.y = displayArea.size.height - theSize.height;
					}
					
					//Cap the arrow offset
					yArrowOffset = MAX(yArrowOffset, self.properties.topBackgroundMargin + self.properties.arrowMargin);
					yArrowOffset = MIN(yArrowOffset, theSize.height - self.properties.bottomBackgroundMargin - self.properties.arrowMargin - rightArrowImage.size.height);
					
					theArrowRect = CGRectMake(xArrowOffset, yArrowOffset, rightArrowImage.size.width, rightArrowImage.size.height);
					
					break;
                default:
                    break;
			}
			
			CGRect bgFrame = CGRectOffset(theBgRect, theOffset.x, theOffset.y);
			
			CGFloat minMarginLeft = CGRectGetMinX(bgFrame);
			CGFloat minMarginRight = CGRectGetWidth(displayArea) - CGRectGetMaxX(bgFrame); 
			CGFloat minMarginTop = CGRectGetMinY(bgFrame); 
			CGFloat minMarginBottom = CGRectGetHeight(displayArea) - CGRectGetMaxY(bgFrame); 
			
			if (minMarginLeft < 0) {
			    // Popover is too wide and clipped on the left; decrease width
			    // and move it to the right
			    theOffset.x -= minMarginLeft;
			    theBgRect.size.width += minMarginLeft;
			    minMarginLeft = 0;
			    if (theArrowDirection == UIPopoverArrowDirectionRight) {
			        theArrowRect.origin.x = CGRectGetMaxX(theBgRect) - self.properties.rightBackgroundMargin;
			    }
			}
			if (minMarginRight < 0) {
			    // Popover is too wide and clipped on the right; decrease width.
			    theBgRect.size.width += minMarginRight;
			    minMarginRight = 0;
			    if (theArrowDirection == UIPopoverArrowDirectionLeft) {
			        theArrowRect.origin.x = CGRectGetMinX(theBgRect) - leftArrowImage.size.width + self.properties.leftBackgroundMargin;
			    }
			}
			if (minMarginTop < 0) {
			    // Popover is too high and clipped at the top; decrease height
			    // and move it down
			    theOffset.y -= minMarginTop;
			    theBgRect.size.height += minMarginTop;
			    minMarginTop = 0;
			    if (theArrowDirection == UIPopoverArrowDirectionDown) {
			        theArrowRect.origin.y = CGRectGetMaxY(theBgRect) - self.properties.bottomBackgroundMargin;
			    }
			}
			if (minMarginBottom < 0) {
			    // Popover is too high and clipped at the bottom; decrease height.
			    theBgRect.size.height += minMarginBottom;
			    minMarginBottom = 0;
			    if (theArrowDirection == UIPopoverArrowDirectionUp) {
			        theArrowRect.origin.y = CGRectGetMinY(theBgRect) - upArrowImage.size.height + self.properties.topBackgroundMargin;
			    }
			}
			bgFrame = CGRectOffset(theBgRect, theOffset.x, theOffset.y);
            
			CGFloat minMargin = MIN(minMarginLeft, minMarginRight);
			minMargin = MIN(minMargin, minMarginTop);
			minMargin = MIN(minMargin, minMarginBottom);
			
			// Calculate intersection and surface
			CGFloat surface = theBgRect.size.width * theBgRect.size.height;
			
			if (surface >= biggestSurface && minMargin >= currentMinMargin) {
				biggestSurface = surface;
                self.offset = CGPointMake(theOffset.x + displayArea.origin.x, theOffset.y + displayArea.origin.y);
                self.arrowRect = theArrowRect;
                self.backgroundRect = theBgRect;
                self.arrowDirection = theArrowDirection;
				currentMinMargin = minMargin;
			}
		}
		
		theArrowDirection <<= 1;
	}
	
	switch (self.arrowDirection) {
		case UIPopoverArrowDirectionUp:
			self.arrowImage = upArrowImage;
			break;
		case UIPopoverArrowDirectionDown:
			self.arrowImage = downArrowImage;
			break;
		case UIPopoverArrowDirectionLeft:
			self.arrowImage = leftArrowImage;
			break;
		case UIPopoverArrowDirectionRight:
			self.arrowImage = rightArrowImage;
			break;
        default:
            break;
	}
}

@end