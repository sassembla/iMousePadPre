//
//  KeyboardButtonManager.h
//  MousePadPre
//
//  Created by illusionismine on 2014/09/23.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KSMessenger.h"

#import "KeysData.h"

#import "ButtonViewControllerDelegate.h"


typedef NS_ENUM(int, INPUT_TYPE) {
    INPUT_TYPE_MOUSEBUTTON,
    INPUT_TYPE_KEY
};



typedef NS_ENUM(int, MESSAGE_BUTTON) {
    BUTTON_MESSAGE_UPDATED
};


@interface KeyboardButtonManager : NSObject <ButtonViewControllerDelegate> {
    KSMessenger *messenger;
}

- (id) initWithBaseView:(UIView *)baseView andSetting:(NSArray *)settings;
- (KeysData)keysData;

@end
