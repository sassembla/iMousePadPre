//
//  KeyButtonViewController.m
//  MousePadPre
//
//  Created by illusionismine on 2014/10/05.
//  Copyright (c) 2014年 KISSAKI. All rights reserved.
//

#import "KeyButtonViewController.h"

@interface KeyButtonViewController ()

@end

@implementation KeyButtonViewController

int buttonIndex;
int mouseButtonType;
NSString *buttonTitle;

- (id) initWithKeyType:(int)type withIndex:(int)index andTitle:(NSString *)title {
    if (self = [super init]) {
        buttonIndex = index;
        mouseButtonType = type;
        
        buttonTitle = [[NSString alloc]initWithString:title];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    for (UIButton *buttonView in [self.view subviews]) {
//        [buttonView.titleLabel setText:buttonTitle];
//    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchDown:(id)sender {
    NSLog(@"!!??");
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
