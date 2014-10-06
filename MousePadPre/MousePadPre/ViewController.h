//
//  ViewController.h
//  MousePadPre
//
//  Created by illusionismine on 2014/09/18.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSMessenger.h"

@interface ViewController : UIViewController {
    KSMessenger *messenger;
}

@property (weak, nonatomic) IBOutlet UIButton *indicatorButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicatorCircle;
@property (weak, nonatomic) IBOutlet UILabel *infoMessage;

@end

