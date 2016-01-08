//
//  ViewController.m
//  3DTouchImitates
//
//  Created by hejunqiu on 16/1/6.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import "ViewController.h"
#import "CHPreviewAssistant.h"

@class CHEffectivePeekWindow;
@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString *> *data;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) CHEffectivePeekWindow *widnow;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _data = @[@"1111",@"1111",@"1111",@"1111",@"1111",@"1111",@"1111",@"1111",@"1111",@"1111",@"1111",@"1111"];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 64)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];

    _button = [[UIButton alloc] initWithFrame:CGRectMake(50, 64 + 150, 150, 80)];
    [_button setTitle:@"UIWindow Test" forState:UIControlStateNormal];
    _button.backgroundColor = [UIColor redColor];
    _button.userInteractionEnabled = YES;
    [_button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *const key = @"key";
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:key];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:key];
    }
    cell.textLabel.text = _data[indexPath.row];
    return cell;
}

- (void)onButtonClicked:(id)sender
{
    if (!_widnow) {
        _widnow = [[CHEffectivePeekWindow alloc] initWithPreviewing:nil];
        _widnow.previewViewController = self;
        [_widnow show];
    }
}

- (NSArray<id<CHUIPreviewActionItem>> *)CHPreviewActionItems
{
    // 生成UIPreviewAction
    CHUIPreviewAction *action1 = [CHUIPreviewAction actionWithTitle:@"Action 1"
                                                              style:CHUIPreviewActionStyleDefault
                                                            handler:^(CHUIPreviewAction * action, UIViewController * previewViewController) {
                                                                NSLog(@"Action 1 selected");}];

    CHUIPreviewAction *action2 = [CHUIPreviewAction actionWithTitle:@"Action 2"
                                                              style:CHUIPreviewActionStyleDestructive
                                                            handler:^(CHUIPreviewAction * action, UIViewController * previewViewController) {
                                                                NSLog(@"Action 2 selected");}];

    CHUIPreviewAction *action3 = [CHUIPreviewAction actionWithTitle:@"Action 3"
                                                              style:CHUIPreviewActionStyleSelected
                                                            handler:^(CHUIPreviewAction * action, UIViewController * previewViewController) { NSLog(@"Action 3 selected");}];
    return @[action1, action2, action3];
}
@end
