//
//  KeyButtonViewController.h
//  MousePadPre
//
//  Created by illusionismine on 2014/10/05.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ButtonViewControllerDelegate.h"

@interface KeyButtonViewController : UIViewController {
    int buttonIndex;
    NSString *buttonTitle;
}

@property (nonatomic,assign) id <ButtonViewControllerDelegate> delegate;
- (id) initWithIndex:(NSNumber *)index andTitle:(NSString *)title;
@end
