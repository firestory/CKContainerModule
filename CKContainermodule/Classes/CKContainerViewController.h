//
//  CKContainerViewController.h
//  Kika
//
//  Created by fadil.zeng on 2021/4/21.
//  Copyright © 2021 ANXIANGZI. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CKContainerViewController : UIViewController

@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, strong, readonly) UIView *selectedViewControllerView;

//@property (nonatomic, strong) UIView *currentClientView;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) UIViewController *selectedViewController;
@property (nonatomic, copy) NSArray<UIViewController *> *viewControllers;
@property (nonatomic, strong) NSMutableArray<NSString *> *vcTitles;

//更多的子控制器切换方法慢慢添加

/// 初始化方法
/// @param vcs 控制器组
- (instancetype)initWithViewControllers:(NSArray *)vcs;

/// 数组下标变化时触发
/// @param fromIndex 前一个index
/// @param toIndex 选中的index
- (void)containerDidChangeViewControll:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

/// 子视图已经移到容器VC上了 子类如有需要进一步布局可在这里。
- (void)contentViewControllerDidMoveToParent:(UIViewController *)vc;

-(CGFloat)mNavigationbarHeight;


@end

NS_ASSUME_NONNULL_END
