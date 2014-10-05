//
//  KeyboardButtonManager.h
//  MousePadPre
//
//  Created by illusionismine on 2014/09/23.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeysData.h"

#import "ButtonViewControllerDelegate.h"

typedef NS_ENUM(int, INPUT_TYPE) {
    INPUT_TYPE_MOUSEBUTTON,
    INPUT_TYPE_KEY
};

@interface KeyboardButtonManager : NSObject <ButtonViewControllerDelegate>

- (id) initWithBaseView:(UIView *)baseView andSetting:(NSArray *)settings;
- (KeysData *)keysData;

@end
