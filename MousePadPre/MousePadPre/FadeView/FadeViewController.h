//
//  FadeViewController.h
//  MousePadPre
//
//  Created by illusionismine on 2014/10/06.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSMessenger.h"

typedef NS_ENUM(int, MESSAGE_FADEOUT) {
    FADEOUT_MESSAGE_FADEOUT,
    FADEOUT_MESSAGE_FADEIN
};


@interface FadeViewController : UIViewController {
    KSMessenger *messenger;
    
    CGRect baseFrame;
}

- (id) initFadeViewWithBaseView:(CGRect)frame;

@end
