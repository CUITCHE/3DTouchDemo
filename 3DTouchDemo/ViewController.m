//
//  ViewController.m
//  3DTouchDemo
//
//  Created by hejunqiu on 16/1/4.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import "ViewController.h"
#import "PeekDemoViewController.h"

@interface ViewController () <UIViewControllerPreviewingDelegate>
@property (nonatomic, strong) UILabel *label;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _label = [[UILabel alloc] initWithFrame:CGRectMake(20, 400, 100, 80)];
    _label.backgroundColor = [UIColor blueColor];
    _label.font = [UIFont systemFontOfSize:19];
    _label.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"MyString"];
    _label.userInteractionEnabled = YES;
    [self.view addSubview:_label];
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:_label];
    }
}

- (void)didReceiveMemoryWarning
{

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - peek
- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location
{
    // 由于这个方法在整个touch过程中会触发多次，所以我们要保证只需要返回一个需要peek的实例即可。
    if ([self.presentedViewController isKindOfClass:[PeekDemoViewController class]]) {
        return nil;
    } else {
        PeekDemoViewController *pdvc = [[PeekDemoViewController alloc] init];
        // 此属性与UIViewController.view.frame相关，但是只有height有效
//        pdvc.preferredContentSize = CGSizeMake(0, 200);
        pdvc.text = _label.text;
        return pdvc;
    }
}

#pragma makr - pop
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    // 用户再次点击屏幕时，调用此方法——用这种方法调用比较优雅，简单
    [self showViewController:viewControllerToCommit sender:self];
}
@end
