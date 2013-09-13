//
//  WEPopoverContainerViewProperties.m
//  WEPopover
//
//  Created by Werner Altewischer on 02/09/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import "WEPopoverContainerView.h"

@implementation WEPopoverContainerViewProperties

+ (WEPopoverContainerViewProperties *)defaultProperties {
    WEPopoverContainerViewProperties *properties = [WEPopoverContainerViewProperties new];

    NSString *backgroundImageName = @"popoverBgSimple.png";
    CGFloat backgroundMargin = 6.0;
    CGFloat contentMargin = 2.0;
    CGFloat backgroundCapSize = 10.0;

    properties.leftBackgroundMargin = backgroundMargin;
    properties.rightBackgroundMargin = backgroundMargin;
    properties.topBackgroundMargin = backgroundMargin;
    properties.bottomBackgroundMargin = backgroundMargin;
    properties.leftBackgroundCapSize = backgroundCapSize;
    properties.rightBackgroundCapSize = backgroundCapSize;
    properties.topBackgroundCapSize = backgroundCapSize;
    properties.bottomBackgroundCapSize = backgroundCapSize;
    properties.backgroundImageName = backgroundImageName;
    properties.leftContentMargin = contentMargin;
    properties.rightContentMargin = contentMargin;
    properties.topContentMargin = contentMargin;
    properties.bottomContentMargin = contentMargin;
    properties.arrowMargin = 1.0;

    properties.upArrowImageName = @"popoverArrowUpSimple.png";
    properties.downArrowImageName = @"popoverArrowDownSimple.png";
    properties.leftArrowImageName = @"popoverArrowLeftSimple.png";
    properties.rightArrowImageName = @"popoverArrowRightSimple.png";
    return properties;
}

@end


@interface WEPopoverContainerView ()

@property(nonatomic) UIPopoverArrowDirection arrowDirection;
@property(nonatomic, strong) UIImage *backgroundImage;
@property(nonatomic, strong) UIImage *arrowImage;
@property(nonatomic, strong) WEPopoverContainerViewProperties *properties;
@property(nonatomic, strong) UIImage *upArrowImage;
@property(nonatomic, strong) UIImage *downArrowImage;
@property(nonatomic, strong) UIImage *leftArrowImage;
@property(nonatomic, strong) UIImage *rightArrowImage;

@property(nonatomic) CGRect backgroundRect;
@property(nonatomic) CGRect arrowRect;
@property(nonatomic) CGPoint backgroundOffset;
@property(nonatomic) CGPoint arrowOffset;
@property(nonatomic) CGFloat arrowOffsetFromBackground;

@end


@implementation WEPopoverContainerView

#pragma mark - Inits, Getters & Setters

- (id)initWithSize:(CGSize)size
        anchorRect:(CGRect)anchorRect
              displayRect:(CGRect)displayRect
arrowOffsetFromBackground:(CGFloat)arrowOffsetFromBackground
 permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections
               properties:(WEPopoverContainerViewProperties *)properties {

    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.properties = properties;
        self.arrowOffsetFromBackground = arrowOffsetFromBackground;
        self.upArrowImage = [UIImage imageNamed:self.properties.upArrowImageName];
        self.downArrowImage = [UIImage imageNamed:self.properties.downArrowImageName];
        self.leftArrowImage = [UIImage imageNamed:self.properties.leftArrowImageName];
        self.rightArrowImage = [UIImage imageNamed:self.properties.rightArrowImageName];

        CGSize correctedSize = CGSizeMake(
                size.width + self.properties.leftBackgroundMargin + self.properties.rightBackgroundMargin + self.properties.leftContentMargin + self.properties.rightContentMargin,
                size.height + self.properties.topBackgroundMargin + self.properties.bottomBackgroundMargin + self.properties.topContentMargin + self.properties.bottomContentMargin);
        [self determineGeometryForSize:correctedSize
                            anchorRect:anchorRect
                           displayRect:displayRect
             arrowOffsetFromBackground:self.arrowOffsetFromBackground
              permittedArrowDirections:permittedArrowDirections];
        [self initFrame];

        self.backgroundColor = [UIColor clearColor];
        UIEdgeInsets backgroundImageInsets = UIEdgeInsetsMake(
                self.properties.topBackgroundCapSize,
                self.properties.leftBackgroundCapSize,
                self.properties.bottomBackgroundCapSize,
                self.properties.rightBackgroundCapSize);
        self.backgroundImage = [[UIImage imageNamed:self.properties.backgroundImageName]
                resizableImageWithCapInsets:backgroundImageInsets
                               resizingMode:UIImageResizingModeStretch];
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setContentView:(UIView *)view {
    if (view != _contentView) {
        _contentView = view;
        _contentView.frame = self.contentRect;
        [self addSubview:_contentView];
    }
}

#pragma mark - Override Methods

- (void)drawRect:(CGRect)rect {
    [self.backgroundImage drawInRect:self.backgroundRect
                           blendMode:kCGBlendModeNormal
                               alpha:1.0];
    [self.arrowImage drawInRect:self.arrowRect
                      blendMode:kCGBlendModeNormal
                          alpha:1.0];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

}

#pragma mark - Public APIs

- (void)updatePositionWithSize:(CGSize)size
                    anchorRect:(CGRect)anchorRect
                   displayRect:(CGRect)displayRect
      permittedArrowDirections:(UIPopoverArrowDirection)permittedArrowDirections {

    CGSize correctedSize = CGSizeMake(
            size.width + self.properties.leftBackgroundMargin + self.properties.rightBackgroundMargin + self.properties.leftContentMargin + self.properties.rightContentMargin,
            size.height + self.properties.topBackgroundMargin + self.properties.bottomBackgroundMargin + self.properties.topContentMargin + self.properties.bottomContentMargin);
    [self determineGeometryForSize:correctedSize
                        anchorRect:anchorRect
                       displayRect:displayRect
         arrowOffsetFromBackground:self.arrowOffsetFromBackground
          permittedArrowDirections:permittedArrowDirections];
    [self initFrame];
    [self setNeedsDisplay];
}

#pragma mark - Private methods

/**
 * The rectangle in which the contentView is contained. It is positioned within the backgroundImage's frame with
 * customized background margin and content margin
 */
- (CGRect)contentRect {
    CGRect rect = CGRectMake(
            self.properties.leftBackgroundMargin + self.properties.leftContentMargin + self.arrowOffset.x,
            self.properties.topBackgroundMargin + self.properties.topContentMargin + self.arrowOffset.y,
            self.backgroundRect.size.width - self.properties.leftBackgroundMargin - self.properties.rightBackgroundMargin - self.properties.leftContentMargin - self.properties.rightContentMargin,
            self.backgroundRect.size.height - self.properties.topBackgroundMargin - self.properties.bottomBackgroundMargin - self.properties.topContentMargin - self.properties.bottomContentMargin);
    return rect;
}

- (CGSize)contentSize {
    return self.contentRect.size;
}

- (void)setProperties:(WEPopoverContainerViewProperties *)properties {
    if (_properties != properties) {
        _properties = properties;
    }
}

- (void)initFrame {
    CGRect containerFrame = CGRectOffset(CGRectUnion(self.backgroundRect, self.arrowRect), self.backgroundOffset.x, self.backgroundOffset.y);

    // If arrow rect origin is < 0 the frame above is extended to include it so we should offset the other rects
    self.arrowOffset = CGPointMake(MAX(0, -self.arrowRect.origin.x), MAX(0, -self.arrowRect.origin.y));
    self.arrowRect = CGRectOffset(self.arrowRect, self.arrowOffset.x, self.arrowOffset.y);
    self.backgroundRect = CGRectOffset(self.backgroundRect, self.arrowOffset.x, self.arrowOffset.y);

    self.frame = CGRectIntegral(containerFrame);
}

- (void)determineGeometryForSize:(CGSize)size
                      anchorRect:(CGRect)anchorRect
                     displayRect:(CGRect)displayRect
       arrowOffsetFromBackground:(CGFloat)arrowOffsetFromBackground
        permittedArrowDirections:(UIPopoverArrowDirection)supportedArrowDirections {

    // Determine the frame, it should not go outside the display area
    UIPopoverArrowDirection arrowDirection = UIPopoverArrowDirectionUp;

    self.backgroundOffset = CGPointZero;
    self.backgroundRect = CGRectZero;
    self.arrowRect = CGRectZero;
    self.arrowDirection = UIPopoverArrowDirectionUnknown;

    CGFloat biggestSurface = 0.0f;
    CGFloat currentMinMargin = 0.0f;

    while (arrowDirection <= UIPopoverArrowDirectionRight) {

        if ((supportedArrowDirections & arrowDirection)) {

            CGRect backgroundRect = CGRectMake(0, 0, size.width, size.height);
            CGRect arrowRect = CGRectZero;
            CGPoint backgroundOffset = CGPointZero;
            CGFloat xArrowOffset = 0.0;
            CGFloat yArrowOffset = 0.0;
            CGPoint anchorPoint = CGPointZero;

            switch (arrowDirection) {
                case UIPopoverArrowDirectionUp:

                    anchorPoint = CGPointMake(
                            CGRectGetMidX(anchorRect) - displayRect.origin.x,
                            CGRectGetMaxY(anchorRect) - displayRect.origin.y);

                    xArrowOffset = size.width / 2 - self.upArrowImage.size.width / 2 + arrowOffsetFromBackground;
                    yArrowOffset = self.properties.topBackgroundMargin - self.upArrowImage.size.height;

                    backgroundOffset = CGPointMake(
                            anchorPoint.x - size.width / 2 - arrowOffsetFromBackground,
                            anchorPoint.y - yArrowOffset);

                    if (backgroundOffset.x < 0) {
                        xArrowOffset += backgroundOffset.x;
                        backgroundOffset.x = 0;
                    } else if (backgroundOffset.x + size.width > displayRect.size.width) {
                        xArrowOffset += (backgroundOffset.x + size.width - displayRect.size.width);
                        backgroundOffset.x = displayRect.size.width - size.width;
                    }

                    // Cap the arrow containerViewOffset
                    xArrowOffset = MAX(xArrowOffset, self.properties.leftBackgroundMargin + self.properties.arrowMargin);
                    xArrowOffset = MIN(xArrowOffset, size.width - self.properties.rightBackgroundMargin - self.properties.arrowMargin - self.upArrowImage.size.width);

                    arrowRect = CGRectMake(xArrowOffset, yArrowOffset, self.upArrowImage.size.width, self.upArrowImage.size.height);

                    break;
                case UIPopoverArrowDirectionDown:

                    anchorPoint = CGPointMake(
                            CGRectGetMidX(anchorRect) - displayRect.origin.x,
                            CGRectGetMinY(anchorRect) - displayRect.origin.y);

                    xArrowOffset = size.width / 2 - self.downArrowImage.size.width / 2 + arrowOffsetFromBackground;
                    yArrowOffset = size.height - self.properties.bottomBackgroundMargin;

                    backgroundOffset = CGPointMake(
                            anchorPoint.x - size.width / 2 - arrowOffsetFromBackground,
                            anchorPoint.y - yArrowOffset - self.downArrowImage.size.height);

                    if (backgroundOffset.x < 0) {
                        xArrowOffset += backgroundOffset.x;
                        backgroundOffset.x = 0;
                    } else if (backgroundOffset.x + size.width > displayRect.size.width) {
                        xArrowOffset += (backgroundOffset.x + size.width - displayRect.size.width);
                        backgroundOffset.x = displayRect.size.width - size.width;
                    }

                    // Cap the arrow containerViewOffset
                    xArrowOffset = MAX(xArrowOffset, self.properties.leftBackgroundMargin + self.properties.arrowMargin);
                    xArrowOffset = MIN(xArrowOffset, size.width - self.properties.rightBackgroundMargin - self.properties.arrowMargin - self.downArrowImage.size.width);

                    arrowRect = CGRectMake(xArrowOffset, yArrowOffset, self.downArrowImage.size.width, self.downArrowImage.size.height);

                    break;
                case UIPopoverArrowDirectionLeft:

                    anchorPoint = CGPointMake(
                            CGRectGetMaxX(anchorRect) - displayRect.origin.x,
                            CGRectGetMidY(anchorRect) - displayRect.origin.y);

                    xArrowOffset = self.properties.leftBackgroundMargin - self.leftArrowImage.size.width;
                    yArrowOffset = size.height / 2 - self.leftArrowImage.size.height / 2 + arrowOffsetFromBackground;

                    backgroundOffset = CGPointMake(
                            anchorPoint.x - xArrowOffset,
                            anchorPoint.y - size.height / 2 - arrowOffsetFromBackground);

                    if (backgroundOffset.y < 0) {
                        yArrowOffset += backgroundOffset.y;
                        backgroundOffset.y = 0;
                    } else if (backgroundOffset.y + size.height > displayRect.size.height) {
                        yArrowOffset += (backgroundOffset.y + size.height - displayRect.size.height);
                        backgroundOffset.y = displayRect.size.height - size.height;
                    }

                    // Cap the arrow containerViewOffset
                    yArrowOffset = MAX(yArrowOffset, self.properties.topBackgroundMargin + self.properties.arrowMargin);
                    yArrowOffset = MIN(yArrowOffset, size.height - self.properties.bottomBackgroundMargin - self.properties.arrowMargin - self.leftArrowImage.size.height);

                    arrowRect = CGRectMake(xArrowOffset, yArrowOffset, self.leftArrowImage.size.width, self.leftArrowImage.size.height);

                    break;
                case UIPopoverArrowDirectionRight:

                    anchorPoint = CGPointMake(CGRectGetMinX(anchorRect) - displayRect.origin.x, CGRectGetMidY(anchorRect) - displayRect.origin.y);

                    xArrowOffset = size.width - self.properties.rightBackgroundMargin;
                    yArrowOffset = size.height / 2 - self.rightArrowImage.size.width / 2 + arrowOffsetFromBackground;

                    backgroundOffset = CGPointMake(
                            anchorPoint.x - xArrowOffset - self.rightArrowImage.size.width,
                            anchorPoint.y - size.height / 2 - arrowOffsetFromBackground);

                    if (backgroundOffset.y < 0) {
                        yArrowOffset += backgroundOffset.y;
                        backgroundOffset.y = 0;
                    } else if (backgroundOffset.y + size.height > displayRect.size.height) {
                        yArrowOffset += (backgroundOffset.y + size.height - displayRect.size.height);
                        backgroundOffset.y = displayRect.size.height - size.height;
                    }

                    // Cap the arrow containerViewOffset
                    yArrowOffset = MAX(yArrowOffset, self.properties.topBackgroundMargin + self.properties.arrowMargin);
                    yArrowOffset = MIN(yArrowOffset, size.height - self.properties.bottomBackgroundMargin - self.properties.arrowMargin - self.rightArrowImage.size.height);

                    arrowRect = CGRectMake(xArrowOffset, yArrowOffset, self.rightArrowImage.size.width, self.rightArrowImage.size.height);

                    break;
                default:
                    break;
            }

            CGRect backgroundFrame = CGRectOffset(backgroundRect, backgroundOffset.x, backgroundOffset.y);

            CGFloat minMarginLeft = CGRectGetMinX(backgroundFrame);
            CGFloat minMarginRight = CGRectGetWidth(displayRect) - CGRectGetMaxX(backgroundFrame);
            CGFloat minMarginTop = CGRectGetMinY(backgroundFrame);
            CGFloat minMarginBottom = CGRectGetHeight(displayRect) - CGRectGetMaxY(backgroundFrame);

            if (minMarginLeft < 0) {
                // Popover is too wide and clipped on the left; decrease width
                // and move it to the right
                backgroundOffset.x -= minMarginLeft;
                backgroundRect.size.width += minMarginLeft;
                minMarginLeft = 0;
                if (arrowDirection == UIPopoverArrowDirectionRight) {
                    arrowRect.origin.x = CGRectGetMaxX(backgroundRect) - self.properties.rightBackgroundMargin;
                }
            }
            if (minMarginRight < 0) {
                // Popover is too wide and clipped on the right; decrease width.
                backgroundRect.size.width += minMarginRight;
                minMarginRight = 0;
                if (arrowDirection == UIPopoverArrowDirectionLeft) {
                    arrowRect.origin.x = CGRectGetMinX(backgroundRect) - self.leftArrowImage.size.width + self.properties.leftBackgroundMargin;
                }
            }
            if (minMarginTop < 0) {
                // Popover is too high and clipped at the top; decrease height
                // and move it down
                backgroundOffset.y -= minMarginTop;
                backgroundRect.size.height += minMarginTop;
                minMarginTop = 0;
                if (arrowDirection == UIPopoverArrowDirectionDown) {
                    arrowRect.origin.y = CGRectGetMaxY(backgroundRect) - self.properties.bottomBackgroundMargin;
                }
            }
            if (minMarginBottom < 0) {
                // Popover is too high and clipped at the bottom; decrease height.
                backgroundRect.size.height += minMarginBottom;
                minMarginBottom = 0;
                if (arrowDirection == UIPopoverArrowDirectionUp) {
                    arrowRect.origin.y = CGRectGetMinY(backgroundRect) - self.upArrowImage.size.height + self.properties.topBackgroundMargin;
                }
            }

            CGFloat minMargin = MIN(minMarginLeft, minMarginRight);
            minMargin = MIN(minMargin, minMarginTop);
            minMargin = MIN(minMargin, minMarginBottom);

            // Calculate intersection and surface
            CGFloat surface = backgroundRect.size.width * backgroundRect.size.height;

            if (surface >= biggestSurface && minMargin >= currentMinMargin) {
                biggestSurface = surface;
                self.backgroundOffset = CGPointMake(backgroundOffset.x + displayRect.origin.x, backgroundOffset.y + displayRect.origin.y);
                self.arrowRect = arrowRect;
                self.backgroundRect = backgroundRect;
                self.arrowDirection = arrowDirection;
                currentMinMargin = minMargin;
            }
        }

        arrowDirection <<= 1;
    }

    switch (self.arrowDirection) {
        case UIPopoverArrowDirectionUp:
            self.arrowImage = self.upArrowImage;
            break;
        case UIPopoverArrowDirectionDown:
            self.arrowImage = self.downArrowImage;
            break;
        case UIPopoverArrowDirectionLeft:
            self.arrowImage = self.leftArrowImage;
            break;
        case UIPopoverArrowDirectionRight:
            self.arrowImage = self.rightArrowImage;
            break;
        default:
            break;
    }
}


@end