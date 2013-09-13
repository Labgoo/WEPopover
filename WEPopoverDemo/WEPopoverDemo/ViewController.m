//
//  ViewController.m
//  WEPopoverDemo
//
//  Created by Minh Tu Le on 9/10/13.
//  Copyright (c) 2013 Minh Tu Le. All rights reserved.
//

#import "ViewController.h"
#import "WEPopoverController.h"

typedef NS_ENUM(NSInteger, AnimationType) {
    kAnimationTypeNoAnimation = 0,
    kAnimationTypeDefaultAnimation,
    kAnimationTypeCustomAnimation
};

NSString *const kNoAnimationTitle = @"No Animation";
NSString *const kDefaultAnimationsTitle = @"Default Animations";
NSString *const kCustomAnimationTitle = @"Custom Animations";


@interface ViewController ()

@property(nonatomic, strong) WEPopoverController *customPopoverController;
@property(nonatomic) AnimationType animationType;
@property(nonatomic, strong) NSArray *animationTitles;
@property(nonatomic, strong) IBOutlet UIBarButtonItem *changeAnimationBarButtonItem;
@property(nonatomic, strong) IBOutlet UIView *touchableView;
@property (strong, nonatomic) IBOutlet UIView *blackBackgroundMaskView;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.animationType = kAnimationTypeDefaultAnimation;
    self.animationTitles = @[kNoAnimationTitle, kDefaultAnimationsTitle, kCustomAnimationTitle];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(showPopupAtTap:)];
    [self.touchableView addGestureRecognizer:tapRecognizer];
    
    self.blackBackgroundMaskView.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)barButtonTapped:(UIBarButtonItem *)button {
    UIViewController *contentViewController = [self createContentViewController:button.title];
    self.customPopoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
    [self.customPopoverController presentPopoverFromBarButtonItem:button
                                         permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                                                         animated:YES];
}

- (IBAction)changeAnimations:(UIBarButtonItem *)button {
    UIViewController *contentViewController = [self createAnimationTypesViewController];
    self.customPopoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
    [self.customPopoverController presentPopoverFromBarButtonItem:button
                                         permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                                                         animated:NO];
}

- (void)showPopupAtTap:(UITapGestureRecognizer *)tapGesture {
    CGPoint tapLocation = [tapGesture locationInView:self.view];
    UIViewController *contentViewController = [self createContentViewController:NSStringFromCGPoint(tapLocation)];
    self.customPopoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
    self.customPopoverController.arrowOffset = 50.0;
    [self showPopupAtRect:CGRectMake(tapLocation.x, tapLocation.y, 0, 0)];
}

- (IBAction)buttonTapped:(UIButton *)button {
    UIViewController *contentViewController = [self createContentViewController:button.titleLabel.text];
    self.customPopoverController = [[WEPopoverController alloc] initWithContentViewController:contentViewController];
    [self showPopupAtRect:button.frame];
}

- (void)closePopover {
    [self.customPopoverController dismissPopoverAnimated:YES];
}

- (void)switchAnimationType:(UIButton *)button {
    self.animationType = (AnimationType) button.tag;
    self.changeAnimationBarButtonItem.title = self.animationTitles[self.animationType];
}


#pragma mark - Private Methods

- (UIViewController *)createContentViewController:(NSString *)title {

    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 150)];
    contentView.backgroundColor = [UIColor whiteColor];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel sizeToFit];
    titleLabel.backgroundColor = [UIColor clearColor];
    [contentView addSubview:titleLabel];
    titleLabel.center = CGPointMake(100, 50);


    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    closeButton.frame = CGRectMake(0, 0, 100, 50);
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton addTarget:self
                    action:@selector(closePopover)
          forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:closeButton];
    closeButton.center = CGPointMake(100, 120);

    UIViewController *contentViewController = [[UIViewController alloc] init];
    contentViewController.view = contentView;
    contentViewController.contentSizeForViewInPopover = contentView.frame.size;

    return contentViewController;
}

- (UIViewController *)createAnimationTypesViewController {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 220)];
    view.backgroundColor = [UIColor whiteColor];

    __block CGFloat y = 15;
    [self.animationTitles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(10, y, 180, 50);
        button.tag = idx;
        [button setTitle:title
                forState:UIControlStateNormal];
        [button addTarget:self
                   action:@selector(switchAnimationType:)
         forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        y += 70;
    }];

    UIViewController *contentViewController = [[UIViewController alloc] init];
    contentViewController.view = view;
    contentViewController.contentSizeForViewInPopover = view.frame.size;

    return contentViewController;
}

- (void)showPopupAtRect:(CGRect)rect {
    switch (self.animationType) {
        case kAnimationTypeNoAnimation:
            [self.customPopoverController presentPopoverFromRect:rect
                                                          inView:self.view
                                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                                        animated:NO];
            break;
        case kAnimationTypeDefaultAnimation:
            [self.customPopoverController presentPopoverFromRect:rect
                                                          inView:self.view
                                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                                        animated:YES];
            break;
        case kAnimationTypeCustomAnimation: {
            [self.customPopoverController presentPopoverFromRect:rect
                                                          inView:self.view
                                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                             appearingAnimations:^{
                                                 CGPoint center = self.customPopoverController.view.center;
                                                 CGPoint enteringPosition;
                                                 self.blackBackgroundMaskView.hidden = NO;
                                                 self.blackBackgroundMaskView.alpha = 0;

                                                 switch (self.customPopoverController.popoverArrowDirection) {
                                                     case UIPopoverArrowDirectionUp:
                                                         enteringPosition = CGPointMake(center.x, center.y + 100);
                                                         break;
                                                     case UIPopoverArrowDirectionDown:
                                                         enteringPosition = CGPointMake(center.x, center.y - 100);
                                                         break;
                                                     case UIPopoverArrowDirectionLeft:
                                                         enteringPosition = CGPointMake(center.x + 100, center.y);
                                                         break;
                                                     case UIPopoverArrowDirectionRight:
                                                         enteringPosition = CGPointMake(center.x - 100, center.y);
                                                         break;
                                                     default:
                                                         enteringPosition = center;
                                                         break;
                                                 }

                                                 self.customPopoverController.view.center = enteringPosition;
                                                 self.customPopoverController.view.alpha = 0.0;
                                                 [UIView animateWithDuration:0.25
                                                                  animations:^{
                                                                      self.customPopoverController.view.center = center;
                                                                      self.customPopoverController.view.alpha = 1.0;
                                                                      self.blackBackgroundMaskView.alpha = 1.0;
                                                                  }];
                                             }
                                          disappearingAnimations:^{
                                              CGPoint center = self.customPopoverController.view.center;
                                              CGPoint leavingPosition;

                                              switch (self.customPopoverController.popoverArrowDirection) {
                                                  case UIPopoverArrowDirectionUp:
                                                      leavingPosition = CGPointMake(center.x, center.y + 100);
                                                      break;
                                                  case UIPopoverArrowDirectionDown:
                                                      leavingPosition = CGPointMake(center.x, center.y - 100);
                                                      break;
                                                  case UIPopoverArrowDirectionLeft:
                                                      leavingPosition = CGPointMake(center.x + 100, center.y);
                                                      break;
                                                  case UIPopoverArrowDirectionRight:
                                                      leavingPosition = CGPointMake(center.x - 100, center.y);
                                                      break;
                                                  default:
                                                      leavingPosition = center;
                                                      break;
                                              }

                                              [UIView animateWithDuration:0.25
                                                                    delay:0.0
                                                                  options:UIViewAnimationOptionCurveEaseOut
                                                               animations:^{
                                                                   self.customPopoverController.view.center = leavingPosition;
                                                                   self.customPopoverController.view.alpha = 0.0;
                                                                   self.blackBackgroundMaskView.alpha = 0.0;
                                                               }
                                                               completion:^(BOOL finished) {
                                                                   self.blackBackgroundMaskView.hidden = YES;
                                                               }];

                                          }];
            break;
        }
        default:
            break;
    }
}


@end
