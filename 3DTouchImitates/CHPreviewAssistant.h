//
//  CHPreviewAssistant.h
//  3DTouchDemo
//
//  Created by hejunqiu on 16/1/6.
//  Copyright © 2016年 hejunqiu. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef SHOCKPROMPT
#define SHOCKPROMPT
#endif

@protocol CHPreviewingDelegate;

NS_CLASS_AVAILABLE_IOS(7_0) @protocol CHPreviewing <NSObject>

// This gesture can be used to cause the previewing presentation to wait until one of your gestures fails or to allow simultaneous recognition during the initial phase of the preview presentation.
@property (nonatomic, readonly) UIGestureRecognizer *previewingGestureRecognizerForFailureRelationship NS_AVAILABLE_IOS(7_0);

@property (nonatomic, readonly) id<CHPreviewingDelegate> delegate NS_AVAILABLE_IOS(7_0);
@property (nonatomic, readonly) UIView *sourceView NS_AVAILABLE_IOS(7_0);

// This rect will be set to the bounds of sourceView before each call to
// -previewingContext:viewControllerForLocation:
@property (nonatomic) CGRect sourceRect NS_AVAILABLE_IOS(7_0);

@end


@protocol CHUIPreviewActionItem;
NS_CLASS_AVAILABLE_IOS(7_0) @interface CHPreviewAssistant : NSObject

//- (NSArray <id <CHUIPreviewActionItem>> *)previewActionItems NS_AVAILABLE_IOS(7_0);

// Registers a view controller to participate with 3D Touch preview (peek) and commit (pop).
- (id <CHPreviewing>)registerForPreviewingWithDelegate:(id<CHPreviewingDelegate>)delegate
                                            sourceView:(UIView *)sourceView NS_AVAILABLE_IOS(7_0);

- (void)unregisterForPreviewingWithContext:(id<CHPreviewing>)previewing NS_AVAILABLE_IOS(7_0);

@end

NS_CLASS_AVAILABLE_IOS(7_0) @protocol CHPreviewingDelegate <NSObject>

// If you return nil, a preview presentation will not be performed
- (UIViewController *)previewingContext:(id<CHPreviewing>)previewingContext
                     viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(7_0);
- (void)previewingContext:(id<CHPreviewing>)previewingContext
            commitViewController:(UIViewController *)viewControllerToCommit NS_AVAILABLE_IOS(7_0);

@end

NS_CLASS_AVAILABLE_IOS(7_0) @protocol CHUIPreviewActionItem <NSObject>
@property (nonatomic, copy, readonly) NSString *title;
@end

typedef NS_ENUM(NSInteger,CHUIPreviewActionStyle) {
    CHUIPreviewActionStyleDefault = 0,
    CHUIPreviewActionStyleSelected,
    CHUIPreviewActionStyleDestructive,
} NS_ENUM_AVAILABLE_IOS(7_0);



NS_CLASS_AVAILABLE_IOS(7_0) @interface CHUIPreviewAction : NSObject <CHUIPreviewActionItem>

@property (nonatomic, copy, readonly) void (^handler)(id<CHUIPreviewActionItem> action, UIViewController *previewViewController);

+ (instancetype)actionWithTitle:(NSString *)title style:(CHUIPreviewActionStyle)style handler:(void (^)(CHUIPreviewAction *action, UIViewController *previewViewController))handler;

@end

NS_CLASS_AVAILABLE_IOS(7_0) @interface CHUIPreviewActionGroup : NSObject <CHUIPreviewActionItem>
+ (instancetype)actionGroupWithTitle:(NSString *)title style:(CHUIPreviewActionStyle)style actions:(NSArray<CHUIPreviewAction *> *)actions;
@end

#pragma mark - 暂时
@interface CHEffectivePeekWindow : UIWindow

@property (nonatomic, weak) UIViewController *previewViewController;

- (instancetype)initWithPreviewing:(id<CHPreviewing>)preview;
- (void)show;
- (void)dismissWithBlock:(void(^)())block;
@end


#pragma mark - UIViewController (CHPreviewActionItems)
@interface UIViewController (CHPreviewActionItems)
- (NSArray<id<CHUIPreviewActionItem>> *)CHPreviewActionItems;
@end