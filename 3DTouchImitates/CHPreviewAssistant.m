//
//  CHPreviewAssistant.m
//  3DTouchDemo
//
//  Created by hejunqiu on 16/1/6.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import "CHPreviewAssistant.h"
#import "AppDelegate.h"

@interface CHPreviewSourceViewRecord : NSObject<CHPreviewing>
@property (nonatomic, weak) UIGestureRecognizer *previewingGestureRecognizerForFailureRelationship NS_AVAILABLE_IOS(7_0);

@property (nonatomic, weak) id<CHPreviewingDelegate> delegate NS_AVAILABLE_IOS(7_0);
@property (nonatomic, weak) UIView *sourceView NS_AVAILABLE_IOS(7_0);

@property (nonatomic) CGRect sourceRect NS_AVAILABLE_IOS(7_0);
@end

@implementation CHPreviewSourceViewRecord

- (instancetype)init
{
    self = [super init];
    if (self) {
        ;
    }
    return self;
}

@end

#pragma makr - CHPreviewAssistant
@interface CHPreviewAssistant ()

@property (nonatomic, strong) NSMutableArray<CHPreviewSourceViewRecord *> *previewPeekPopSourceViewRecords;
@property (nonatomic, weak) UIView *target;

@end

@implementation CHPreviewAssistant

- (instancetype)initWithTarget:(UIView *)target
{
    self = [super init];
    if (self) {
        _previewPeekPopSourceViewRecords = [NSMutableArray array];
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureHandler:)];
        _target = target;
        [_target addGestureRecognizer:_longPressGesture];
    }
    return self;
}

#pragma makr - public
- (id<CHPreviewing>)registerForPreviewingWithDelegate:(id<CHPreviewingDelegate>)delegate sourceView:(UIView *)sourceView
{
    for (CHPreviewSourceViewRecord *record in _previewPeekPopSourceViewRecords) {
        if ([record.delegate isEqual:delegate] && [record.sourceView isEqual:sourceView]) {
            [_previewPeekPopSourceViewRecords removeObject:record];
            break;
        }
    }
    CHPreviewSourceViewRecord *record = [CHPreviewSourceViewRecord new];
    record.delegate = delegate;
    record.sourceView = sourceView;
    [_previewPeekPopSourceViewRecords addObject:record];
    return record;
}

- (void)unregisterForPreviewingWithContext:(id<CHPreviewing>)previewing
{
    [_previewPeekPopSourceViewRecords removeObject:previewing];
}

#pragma mark - helper
- (void)longPressGestureHandler:(UILongPressGestureRecognizer *)gesture
{

}
@end

#pragma mark - CLASS-CHEffectivePeekWindow
const CGFloat lrMargin = 16;
const CGFloat bottomMargin = 32;

@implementation CHEffectivePeekWindow

- (instancetype)initWithPreviewing:(id<CHPreviewing>)preview
{
    CGRect frame = [UIScreen mainScreen].bounds;
    self = [self initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 1;
        _previewHeight = CGRectGetHeight(frame) - CGRectGetMaxY([self visibleViewController].navigationController.navigationBar.frame) - 48;
        _previewTarget = preview;
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
        [self addGestureRecognizer:_panGesture];

        // 毛玻璃效果，这个要写在其它视图的前面
        UIVisualEffectView *visualEffect = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        visualEffect.frame = frame;
        [self addSubview:visualEffect];

        _shadowView = [[UIView alloc] initWithFrame:CGRectZero];
        _shadowView.backgroundColor = [UIColor whiteColor];
        // 设置阴影
        _shadowView.layer.shadowColor = [UIColor grayColor].CGColor;
        _shadowView.layer.shadowOffset = CGSizeMake(0, 0);
        _shadowView.layer.shadowOpacity = 0.8;
        _shadowView.layer.shadowRadius = 4;
        _shadowView.layer.cornerRadius = 20;
        [self addSubview:_shadowView];

        _contentView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = [UIColor whiteColor];
        // 设置圆角
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 20;
        [_shadowView addSubview:_contentView];
    }
    return self;
}

- (void)show
{
    self.hidden = NO;
    [self makeKeyAndVisible];
}

#pragma mark - property
- (void)setPreviewHeight:(CGFloat)previewHeight
{
    if (_previewHeight != previewHeight) {
        _previewHeight = previewHeight;
        [self setNeedsLayout];
    }
}

#pragma mark - helper
- (void)panGestureHandler:(UIPanGestureRecognizer *)gesture
{
    ;
}

- (UIViewController *)visibleViewController
{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    return delegate.rootViewController.visibleViewController;
}

- (UIImage *)capture:(UIView *)view rect:(CGRect)rect scaleToSize:(CGSize)scaleSize
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) {
        return nil;
    }

    // capture full view as a image
    [view.layer.presentationLayer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (!CGRectEqualToRect(view.bounds, rect)) {
        CGFloat scale = [UIScreen mainScreen].scale;

        // prepare real clip rect
        CGRect clipRect = CGRectZero;
        clipRect.origin.x = scale * rect.origin.x;
        clipRect.origin.y = scale * rect.origin.y;
        clipRect.size.width = scale * rect.size.width;
        clipRect.size.height = scale * rect.size.height;

        // clip image with real rect
        CGImageRef cropedImageRef = CGImageCreateWithImageInRect(image.CGImage, clipRect);

        // croped image
        UIImage *cropedImage = [UIImage imageWithCGImage:cropedImageRef];
        CFRelease(cropedImageRef);
        image = cropedImage;
    }
    return image;
}

#pragma mark - override
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize szFrame = self.bounds.size;
    if (szFrame.height <= 0) {
        return;
    }
    CGFloat capturePosY = CGRectGetMaxY([self visibleViewController].navigationController.navigationBar.frame);
    // 得到目标controller的view
    UIView *view = _previewController.view;
    CGRect captureRect = view.frame;
    captureRect.origin.y = capturePosY;
    captureRect.size.height = _previewHeight;
    CGSize scaleSize = CGSizeMake(szFrame.width - 2 * lrMargin, _previewHeight);
    _contentView.image = [self capture:view rect:captureRect scaleToSize:scaleSize];
    // 设置contentView的位置
    CGRect frame = CGRectMake(lrMargin, capturePosY, scaleSize.width, scaleSize.height);
    // 将shadow移至正确的位置。
    _shadowView.frame = frame;
    frame.origin.x = frame.origin.y = 0;
    _contentView.frame = frame;
}
@end

#pragma mark - CLASS-CHUIPreviewAction
@interface CHUIPreviewAction ()
@property (nonatomic, copy) void (^handler)(id<CHUIPreviewActionItem> action, UIViewController *previewViewController);
@property (nonatomic) CHUIPreviewActionStyle previewActionStyle;
@property (nonatomic, copy) NSString *title;
@end

@implementation CHUIPreviewAction

+ (instancetype)actionWithTitle:(NSString *)title style:(CHUIPreviewActionStyle)style handler:(void (^)(CHUIPreviewAction *, UIViewController *))handler
{
    CHUIPreviewAction *previewAction = [[CHUIPreviewAction alloc] init];
    previewAction.title = title;
    previewAction.previewActionStyle = style;
    previewAction.handler = handler;
    return previewAction;
}

@end

#pragma mark - CLASS-CHPreviewActionSheet
@interface CHPreviewActionSheet : UIView

@property (nonatomic, strong) NSMutableArray<CHUIPreviewAction *> *actionItem;
@property (nonatomic, strong) NSMutableArray<__weak UIButton *> *actionButtons;
@property (nonatomic, strong) UIView *contentView;

- (void)addActionItem:(CHUIPreviewAction*)action;
@end

@implementation CHPreviewActionSheet

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:247 green:247 blue:247 alpha:1];
        _actionItem = [NSMutableArray array];
        _actionButtons = [NSMutableArray array];

        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 15;
        [self addSubview:_contentView];
    }
    return self;
}

- (void)addActionItem:(CHUIPreviewAction *)action
{
    [_actionItem addObject:action];
    UIButton *button = [self makeButtonWithActionItem:action];
    [_actionButtons addObject:button];
    [_contentView addSubview:button];
}

#pragma mark - helper
- (UIButton *)makeButtonWithActionItem:(CHUIPreviewAction *)action
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    UIColor *color;
    if (action.previewActionStyle == CHUIPreviewActionStyleDefault) {
        color = [UIColor colorWithRed:54 green:96 blue:254 alpha:1];
    } else if (action.previewActionStyle == CHUIPreviewActionStyleDestructive) {
        color = [UIColor colorWithRed:228 green:32 blue:38 alpha:1];
    }
    [button setTitleColor:color forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    return button;
}
@end