//
//  MouseIndicatorViewController.m
//  MousePadPre
//
//  Created by illusionismine on 2014/10/13.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import "MouseIndicatorViewController.h"

@interface MouseIndicatorViewController ()
@property (weak, nonatomic) IBOutlet UIButton *mouseIndicatorButton;

@property (weak, nonatomic) IBOutlet UIButton *leftIndicator;

@property (weak, nonatomic) IBOutlet UIButton *rightIndicator;

@property (weak, nonatomic) IBOutlet UIButton *centerIndicator;

@end

@implementation MouseIndicatorViewController

- (id) initWithBaseview:(UIView *)baseview {
    if (self = [super init]) {
        [baseview addSubview:self.view];
        self.view.center = baseview.center;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [_mouseIndicatorButton setEnabled:NO];
    
    [self turnLeft:NO];
    [self turnRight:NO];
    [self turnCenter:NO];
}

- (void) turnOn {
    [_mouseIndicatorButton setEnabled:YES];
}

- (void) turnOff {
    [_mouseIndicatorButton setEnabled:NO];
}

- (void) turnLeft:(bool)onOrOff {
    if (onOrOff) {
        [UIView beginAnimations:@"appear" context:nil];
        [_leftIndicator setAlpha:1.0f];
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:@"disappear" context:nil];
        [_leftIndicator setAlpha:0.0f];
        [UIView commitAnimations];
    }
}
- (void) turnRight:(bool)onOrOff {
    if (onOrOff) {
        [UIView beginAnimations:@"appear" context:nil];
        [_rightIndicator setAlpha:1.0f];
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:@"disappear" context:nil];
        [_rightIndicator setAlpha:0.0f];
        [UIView commitAnimations];
    }
}
- (void) turnCenter:(bool)onOrOff {
    if (onOrOff) {
        [UIView beginAnimations:@"appear" context:nil];
        [_centerIndicator setAlpha:1.0f];
        [UIView commitAnimations];
    } else {
        [UIView beginAnimations:@"disappear" context:nil];
        [_centerIndicator setAlpha:0.0f];
        [UIView commitAnimations];
    }
}

@end
