//
//  FadeViewController.m
//  MousePadPre
//
//  Created by illusionismine on 2014/10/06.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import "FadeViewController.h"
#import "Messengers.h"

@interface FadeViewController ()

@end

@implementation FadeViewController

- (id) initFadeViewWithBaseView:(CGRect)frame {
    if (self = [super init]) {
        messenger = [[KSMessenger alloc]initWithBodyID:self withSelector:@selector(receiver:) withName:MESSENGER_FADEVIEWCONTROLLER];
        [messenger connectParent:MESSENGER_MAINVIEWCONTROLLER];
        
        baseFrame = frame;
    }
    
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self.view setFrame:baseFrame];
}


- (void) receiver:(NSNotification *)notif {
    switch ([messenger execFrom:[messenger myParentName] viaNotification:notif]) {
        case FADEOUT_MESSAGE_FADEIN:{
            
            break;
        }
        case FADEOUT_MESSAGE_FADEOUT:{
            
            break;
        }
            
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
