//
//  CHPreviewAssistant.m
//  3DTouchDemo
//
//  Created by hejunqiu on 16/1/6.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import "CHPreviewAssistant.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>

#ifdef SHOCKPROMPT
#warning notice: private API. It will appear when you denfined macro SHOCKPROMPT
extern void AudioServicesPlaySystemSoundWithVibration(int, id, NSDictionary *);
void shock_prompt_(NSTimeInterval shockTime, CGFloat intensity)
{
    NSArray *array = @[@(YES), @(shockTime)];
    NSDictionary *dict = @{@"VibePattern" : array,
                           @"Intensity"   : @(intensity)};
    AudioServicesPlaySystemSoundWithVibration(4095, nil, dict);
}
#define shock_prompt(shockTime, intensity) shock_prompt_((shockTime), (intensity))
#else
#define shock_prompt(shockTime, intensity)
#endif

#pragma mark - CLASS-NSMutableArray (ExtraFind)
@interface NSMutableArray<ObjectType> (ExtraFind)

- (ObjectType)find_if:(BOOL(^)(ObjectType))block;
@end

@implementation NSMutableArray (ExtraFind)

- (id)find_if:(BOOL (^)(id))block
{
    for (id obj in self) {
        if (block(obj)) {
            return obj;
        }
    }
    return nil;
}

@end

@interface CHPreviewSourceViewRecord : NSObject<CHPreviewing>
@property (nonatomic, weak) UILongPressGestureRecognizer *previewingGestureRecognizerForFailureRelationship NS_AVAILABLE_IOS(7_0);

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
@property (nonatomic, strong) CHEffectivePeekWindow *previewingWindow;

@end

@implementation CHPreviewAssistant

- (instancetype)init
{
    self = [super init];
    if (self) {
        _previewPeekPopSourceViewRecords = [NSMutableArray array];
    }
    return self;
}

#pragma makr - public
- (id<CHPreviewing>)registerForPreviewingWithDelegate:(id<CHPreviewingDelegate>)delegate sourceView:(UIView *)sourceView
{
    if (![delegate isKindOfClass:[UIViewController class]]) {
        NSLog(@"delegate=<%@> is expected one which is kind of UIViewController\n", delegate);
        return nil;
    }
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureHandler:)];
    [sourceView addGestureRecognizer:gesture];

    CHPreviewSourceViewRecord *record = [[CHPreviewSourceViewRecord alloc] init];
    record.previewingGestureRecognizerForFailureRelationship = gesture;
    record.delegate = delegate;
    record.sourceView = sourceView;
    [_previewPeekPopSourceViewRecords addObject:record];
    return record;
}

- (void)unregisterForPreviewingWithContext:(id<CHPreviewing>)previewing
{
    if (!([previewing respondsToSelector:@selector(sourceView)] && [previewing respondsToSelector:@selector(previewingGestureRecognizerForFailureRelationship)])) {
        NSLog(@"previewing=<%@> don't contain property:sourceView or previewingGestureRecognizerForFailureRelationship\n", previewing);
        return;
    }
    [previewing.sourceView removeGestureRecognizer:previewing.previewingGestureRecognizerForFailureRelationship];
    [_previewPeekPopSourceViewRecords removeObject:previewing];
}

#pragma mark - helper
- (void)longPressGestureHandler:(UILongPressGestureRecognizer *)gesture
{
    UIView *sourceView = gesture.view;
    CHPreviewSourceViewRecord *record = nil;
    for (CHPreviewSourceViewRecord *recordOne in _previewPeekPopSourceViewRecords) {
        if ([recordOne.sourceView isEqual:sourceView]) {
            record = recordOne;
            break;
        }
    }
    if (!record) {
        return;
    }
    if (gesture.state == UIGestureRecognizerStateBegan) {
        // 引发手机振动，以给用户反馈
        shock_prompt(50, 0.3);
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([record.delegate respondsToSelector:@selector(previewingContext:viewControllerForLocation:)]) {
            CGPoint location = [gesture locationInView:sourceView];
            record.sourceRect = record.sourceView.frame;
            _previewingWindow = [[CHEffectivePeekWindow alloc] initWithPreviewing:record];
            UIViewController *viewController = [record.delegate previewingContext:record viewControllerForLocation:location];
            _previewingWindow.previewViewController = viewController;
        }
    }
}
@end



#pragma mark - CLASS-CHUIPreviewAction
@interface CHUIPreviewAction ()
@property (nonatomic, copy) void (^handler)(id<CHUIPreviewActionItem> action, UIViewController *previewViewController);
@property (nonatomic) CHUIPreviewActionStyle previewActionStyle;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, weak) UIButton *actionButton;
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

#pragma mark - CLASS-CHPreviewActionSheetContentView
const CGFloat kButtonHeight = 60;
const CGFloat lrMargin = 16;
const CGFloat bottomMargin = 32;

@interface CHPreviewActionSheetContentView : UIView
{
    CGFloat _1PixelSize;
}
@property (nonatomic, strong) NSMutableArray<UIView *> *views;
@property (nonatomic, strong) NSMutableArray<UIView *> *lines;
@property (nonatomic, readonly) CGFloat perfectHeight;

@end

@implementation CHPreviewActionSheetContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        _views = [NSMutableArray array];
        _lines = [NSMutableArray array];
        _1PixelSize = 1.f / [UIScreen mainScreen].scale;
    }
    return self;
}

- (void)addSubview:(UIView *)view
{
    [super addSubview:view];
    [_views addObject:view];
    // add line view.
    if (_views.count >= 2) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
        line.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        [super addSubview:line];
        [_lines addObject:line];
    }
}

#pragma mark - property
- (CGFloat)perfectHeight
{
    if (_views.count == 0) {
        return 0;
    }
    return (kButtonHeight + _1PixelSize) * _views.count - _1PixelSize;
}

#pragma mark - override
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat y = 0;
    const CGFloat width = CGRectGetWidth(self.bounds);
    _views.firstObject.frame = CGRectMake(0, y, width, kButtonHeight);
    for (NSUInteger i=0; i<_lines.count; ++i) {
        y += kButtonHeight;
        _lines[i].frame = CGRectMake(0, y, width, _1PixelSize);
        y += _1PixelSize;
        _views[i+1].frame = CGRectMake(0, y, width, kButtonHeight);
    }
}
@end

#pragma mark - CLASS-CHPreviewActionSheet
@interface CHPreviewActionSheet : UIView

@property (nonatomic, strong) NSMutableArray<CHUIPreviewAction *> *actionItems;
@property (nonatomic, strong) CHPreviewActionSheetContentView *contentView;

- (void)addActionItem:(CHUIPreviewAction *)action;
@end

@implementation CHPreviewActionSheet

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _actionItems = [NSMutableArray array];
        _contentView = [[CHPreviewActionSheetContentView alloc] initWithFrame:CGRectZero];
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 15;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 15;
        [self addSubview:_contentView];
    }
    return self;
}

- (void)addActionItem:(CHUIPreviewAction *)action
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    button.userInteractionEnabled = YES;
    UIColor *color = [UIColor redColor];
    if (action.previewActionStyle == CHUIPreviewActionStyleDestructive) {
        color = [UIColor colorWithRed:228/255.0 green:32/255.0 blue:38/255.0 alpha:1];
    } else {
        color = [UIColor colorWithRed:54/255.0 green:96/255.0 blue:254/255.0 alpha:1];
    }
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTitle:action.title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:19];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    action.actionButton = button;

    [_contentView addSubview:button];
    [_actionItems addObject:action];
    [self setNeedsLayout];
}

#pragma mark - helper
- (void)onButtonClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (!button) {
        return;
    }
    CHUIPreviewAction *action = [_actionItems find_if:^BOOL(CHUIPreviewAction *action) {
        return [action.actionButton isEqual:button];
    }];
    if (action) {
        action.handler(action, nil);
    }
}

#pragma mark - override
- (void)sizeToFit
{
    CGRect frame = CGRectZero;
    frame.size.width = [UIScreen mainScreen].bounds.size.width - 2 * lrMargin;
    frame.size.height = _contentView.perfectHeight;
    _contentView.frame = frame;
    frame.origin.x = lrMargin;
    frame.origin.y = [UIScreen mainScreen].bounds.size.height - _contentView.perfectHeight * 1.5;
    self.frame = frame;
}
@end


#pragma mark - CLASS-CHEffectivePeekWindow

@interface CHEffectivePeekWindow ()
/// 默认是从标题栏下到屏幕末的长度减去48pt
@property (nonatomic) CGFloat previewHeight;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, weak) id<CHPreviewing> previewTarget;
@property (nonatomic, strong) UIImageView *contentView;
@property (nonatomic, strong) UIView *shadowView;

@property (nonatomic ,strong) CHPreviewActionSheet *previewActionSheet;
@property (nonatomic) CGRect holdOriginFrame;
@property (nonatomic) BOOL needDismiss;
@end

@implementation CHEffectivePeekWindow

- (instancetype)initWithPreviewing:(id<CHPreviewing>)preview
{
    CGRect frame = [UIScreen mainScreen].bounds;
    self = [self initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 1;
        _needDismiss = YES;
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

- (void)dismissWithBlock:(void (^)())block
{
    self.hidden = YES;
    [self resignKeyWindow];
    if (block) {
        block();
    }
}

#pragma mark - property
- (void)setPreviewHeight:(CGFloat)previewHeight
{
    if (_previewHeight != previewHeight) {
        _previewHeight = previewHeight;
        [self setNeedsLayout];
    }
}

- (void)setPreviewViewController:(UIViewController *)previewViewController
{
    if (![_previewViewController isEqual:previewViewController]) {
        _previewViewController = previewViewController;
        [self makeEffectWindow];
        // 生成action sheet view
        _previewActionSheet = [[CHPreviewActionSheet alloc] initWithFrame:CGRectZero];
        [self addSubview:_previewActionSheet];
        if ([_previewViewController respondsToSelector:@selector(CHPreviewActionItems)]) {
            NSArray<id<CHUIPreviewActionItem>> *aciontItems = [_previewViewController CHPreviewActionItems];
            for (id<CHUIPreviewActionItem> item in aciontItems) {
                [_previewActionSheet addActionItem:item];
            }
        }
        [_previewActionSheet sizeToFit];
        CGRect frame = _previewActionSheet.frame;
        frame.origin.y = CGRectGetMaxY([UIScreen mainScreen].bounds);
        _previewActionSheet.frame = frame;
    }
}

#pragma mark - Gesture
- (void)panGestureHandler:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint touchPoint = [gesture translationInView:self];
        [self updateFrame:touchPoint];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        if (_needDismiss) {
            // TODO: 退出当前Window.
            [self hideActionSheetWithAnimation];
            __weak typeof(self) __weakSelf = self;
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
                _shadowView.frame = _holdOriginFrame;
            } completion:^(BOOL finished) {
                [__weakSelf dismissWithBlock:nil];
            }];
        } else {
            CGFloat space = 16;
            CGRect frame = _previewActionSheet.frame;
            frame.origin.x = lrMargin;
            frame.origin.y = CGRectGetMaxY(self.bounds) - _previewActionSheet.contentView.perfectHeight - space;
            CGRect frame2 = _shadowView.frame;
            frame2.origin.x = lrMargin;
            frame2.origin.y = CGRectGetMaxY([self visibleViewController].navigationController.navigationBar.frame) - CGRectGetHeight(_previewActionSheet.frame);
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
                _shadowView.frame = frame2;
                _previewActionSheet.frame = frame;
            } completion:nil];
        }
    }
    [gesture setTranslation:CGPointZero inView:self];
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

- (void)makeEffectWindow
{
    CGFloat capturePosY = CGRectGetMaxY([self visibleViewController].navigationController.navigationBar.frame);
    // 得到目标controller的view
    UIView *view = _previewViewController.view;
    CGRect captureRect = view.frame;
    captureRect.origin.y = capturePosY;
    captureRect.size.height = _previewHeight;
    CGSize scaleSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 2 * lrMargin, _previewHeight);
    _contentView.image = [self capture:view rect:captureRect scaleToSize:scaleSize];
    // 设置contentView的位置
    CGRect frame = CGRectMake(lrMargin, capturePosY, scaleSize.width, scaleSize.height);
    _holdOriginFrame = frame;
    // 将shadow移至正确的位置。
    _shadowView.frame = frame;
    _shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_shadowView.bounds cornerRadius:20].CGPath;
    frame.origin.x = frame.origin.y = 0;
    _contentView.frame = frame;
}

#pragma mark - animation
- (void)updateFrame:(CGPoint)point
{
    CGFloat space = 16;
    CGRect selfBounds = self.bounds;
    CGFloat actionSheetWillShowPositionY = CGRectGetMaxY(selfBounds) - space - kButtonHeight;
    if (CGRectGetMaxY(_shadowView.frame) + 48 + point.y < CGRectGetMaxY(selfBounds)) {
        _shadowView.frame = CGRectOffset(_shadowView.frame, 0, point.y);
    }
    // 初始状态，以content view为参照物
    if (point.y < 0) {
        if (CGRectGetMaxY(_shadowView.frame) + point.y <= actionSheetWillShowPositionY) {
            if (!_needDismiss) {
                _previewActionSheet.frame = CGRectOffset(_previewActionSheet.frame, 0, point.y);
                return;
            }
            _needDismiss = NO;
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
                CGRect frame = CGRectOffset(_previewActionSheet.frame, 0, CGRectGetMaxY(_shadowView.frame) - CGRectGetMaxY(selfBounds) + space);
                _previewActionSheet.frame = frame;
            } completion:nil];
        }
    } else if (point.y > 0) {
        BOOL needHide = fabs(point.y) > 2;
        if (needHide) {
            _needDismiss = YES;
            [self hideActionSheetWithAnimation];
        } else {
            _previewActionSheet.frame = CGRectOffset(_previewActionSheet.frame, 0, point.y);
        }
    }
}

- (void)hideActionSheetWithAnimation
{
    CGRect frame = _previewActionSheet.frame;
    frame.origin.x = lrMargin;
    frame.origin.y = CGRectGetMaxY(self.bounds);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
        _previewActionSheet.frame = frame;
    } completion:nil];
}

- (void)showActionSheetWithAnimation
{

}
@end
