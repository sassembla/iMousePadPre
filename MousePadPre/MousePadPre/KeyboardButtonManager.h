//
//  KeyboardButtonManager.h
//  MousePadPre
//
//  Created by illusionismine on 2014/09/23.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KeysData.h"

@interface KeyboardButtonManager : NSObject

- (id) initWithBaseView:(UIView *)baseView andSetting:(NSDictionary *)settings;
- (KeysData *)keysData;

@end
