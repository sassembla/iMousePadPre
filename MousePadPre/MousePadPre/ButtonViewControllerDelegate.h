//
//  ButtonViewControllerDelegate.h
//  MousePadPre
//
//  Created by illusionismine on 2014/10/05.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

@protocol ButtonViewControllerDelegate
- (void) touchDown:(int)buttonIndex;
- (void) touchUp:(int)buttonIndex;
@end
