//
//  MouseIndicatorViewController.h
//  MousePadPre
//
//  Created by illusionismine on 2014/10/13.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MouseIndicatorViewController : UIViewController
- (id) initWithBaseview:(UIView *)baseview;

- (void) turnOn;
- (void) turnOff;

- (void) turnLeft:(bool)onOrOff;
- (void) turnRight:(bool)onOrOff;
- (void) turnCenter:(bool)onOrOff;
@end
