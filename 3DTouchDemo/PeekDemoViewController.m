//
//  PeekDemoViewController.m
//  3DTouchDemo
//
//  Created by hejunqiu on 16/1/4.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import "PeekDemoViewController.h"

@interface PeekDemoViewController ()
@property (nonatomic, strong) UITextView *textView;
@end

@implementation PeekDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 建议将需要pop的controller的view设置成White
    self.view.backgroundColor = [UIColor whiteColor];
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth([UIScreen mainScreen].bounds), self.preferredContentSize.height)];
    _textView.text = _text;
    [self.view addSubview:_textView];
}

#pragma makr - 生成地步的Action
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems
{
    // 生成UIPreviewAction
    UIPreviewAction *action1 = [UIPreviewAction actionWithTitle:@"Action 1" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * action, UIViewController * previewViewController) {
        NSLog(@"Action 1 selected");
    }];

    UIPreviewAction *action2 = [UIPreviewAction actionWithTitle:@"Action 2" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * action, UIViewController * previewViewController) {
        NSLog(@"Action 2 selected");
    }];

    UIPreviewAction *action3 = [UIPreviewAction actionWithTitle:@"Action 3" style:UIPreviewActionStyleSelected handler:^(UIPreviewAction * action, UIViewController * previewViewController) {
        NSLog(@"Action 3 selected");
    }];

//    UIPreviewAction *tap1 = [UIPreviewAction actionWithTitle:@"tap 1" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * action, UIViewController * previewViewController) {
//        NSLog(@"tap 1 selected");
//    }];
//
//    UIPreviewAction *tap2 = [UIPreviewAction actionWithTitle:@"tap 2" style:UIPreviewActionStyleDestructive handler:^(UIPreviewAction * action, UIViewController * previewViewController) {
//        NSLog(@"tap 2 selected");
//    }];
//
//    UIPreviewAction *tap3 = [UIPreviewAction actionWithTitle:@"tap 3" style:UIPreviewActionStyleSelected handler:^(UIPreviewAction * action, UIViewController * previewViewController) {
//        NSLog(@"tap 3 selected");
//    }];

    //添加到到UIPreviewActionGroup中
    NSArray *actions = @[action1, action2, action3];
//    NSArray *taps = @[tap1, tap2, tap3];
//    UIPreviewActionGroup *group1 = [UIPreviewActionGroup actionGroupWithTitle:@"Action Group" style:UIPreviewActionStyleDefault actions:actions];
//    UIPreviewActionGroup *group2 = [UIPreviewActionGroup actionGroupWithTitle:@"Tap Group" style:UIPreviewActionStyleDefault actions:taps];
//    NSArray *group = @[group1,group2];

    return actions;
}

@end
