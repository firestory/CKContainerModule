//
//  CKContainerViewController.m
//  Kika
//
//  Created by fadil.zeng on 2021/4/21.
//  Copyright © 2021 ANXIANGZI. All rights reserved.
//

#import "CKContainerViewController.h"

@interface CKContainerViewController ()

//私有属性
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *selectedViewControllerView;

@end

@implementation CKContainerViewController

#pragma mark - setter & getter
- (UIViewController *)selectedViewController{
    if (self.viewControllers == nil || self.selectedIndex < 0 || self.selectedIndex >= self.viewControllers.count) {
        return nil;
    }
    return self.viewControllers[self.selectedIndex];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    if (_selectedIndex != selectedIndex) {
        NSInteger fromIndex = _selectedIndex;
        _selectedIndex = selectedIndex;
        [self transitionViewControllerFromIndex:fromIndex toIndex:selectedIndex];
        if (selectedIndex != NSNotFound) {
            [self containerDidChangeViewControll:fromIndex toIndex:selectedIndex];
        }
    }
}

#pragma mark - system

- (instancetype)initWithViewControllers:(NSArray *)vcs{
    if (self = [super init]) {
        if (!vcs || vcs.count <= 0) {vcs = @[[UIViewController new]];}
        self.viewControllers = vcs;
        _selectedIndex = NSNotFound;
        self.vcTitles = [NSMutableArray arrayWithCapacity:vcs.count];
        for (UIViewController *vc in vcs) {
            vc.view.translatesAutoresizingMaskIntoConstraints = YES;
            vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
            NSString *title = vc.title != nil ? vc.title:@"vc";
            [self.vcTitles addObject:title];
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.viewControllers != nil && self.viewControllers.count > 0 && self.selectedIndex == NSNotFound) {
        self.selectedIndex = 0;
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.opaque = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.containerView = [UIView new];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.containerView.backgroundColor = [UIColor clearColor];
    self.containerView.opaque = YES;
    [self.view addSubview:self.containerView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
    //立即更新约束，方便子类能在viewdidload中不使用约束也能获取到frame。
    [self.view layoutIfNeeded];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//fetch status bar & navi bar height
-(CGFloat)mNavigationbarHeight{
    return self.navigationController.navigationBar.frame.size.height + [[UIApplication sharedApplication] statusBarFrame].size.height;
}

- (void)containerDidChangeViewControll:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    //subclass implementation this
}

- (void)contentViewControllerDidMoveToParent:(UIViewController *)vc{
    //subclass implementation this
}

#pragma mark - container method & api

- (void)customPresentViewController:(UIViewController *)vc complete:(void(^)(void))complete{
    if (!vc) return;
    if (self.selectedViewController == vc) return;
    [self animationPresentFromVC:self.selectedViewController toVC:vc complete:complete];
}

- (void)customDismissViewController:(UIViewController *)vc complete:(void(^)(void))complete{
    if (!vc) return;
    if (![self.viewControllers containsObject:vc]) return;
    [self animationDismissFromVC:vc toVC:self.viewControllers.firstObject complete:complete];
}

#pragma mark - ViewController change

- (void)transitionViewControllerFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    
    if (fromIndex == NSNotFound) {
        UIViewController *selectedVC;
        if (toIndex <= self.viewControllers.count - 1) {
            selectedVC = self.viewControllers[toIndex];
        }else{
            selectedVC = self.viewControllers.firstObject;
        }
        [self displayContentController:selectedVC];
        return;
    }
    
    UIViewController *fromVC = self.viewControllers[fromIndex];
    UIViewController *toVC = self.viewControllers[toIndex];
        
    [self hideContentController:fromVC];
    [self displayContentController:toVC];

}

- (void)displayContentController:(UIViewController*)content{
    if (!content) {return;}
    [self addChildViewController:content];
    content.view.frame = self.view.frame;
    [self.containerView addSubview:content.view];
    self.selectedViewControllerView = content.view;
//    [self frameForContentController];
    [content didMoveToParentViewController:self];
    [self contentViewControllerDidMoveToParent:content];
}

- (void)hideContentController:(UIViewController*)content{
    [content willMoveToParentViewController:nil];
    self.selectedViewControllerView = nil;
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

- (void)animationPresentFromVC:(UIViewController*)fromVC toVC:(UIViewController *)toVC complete:(void(^)(void))complete{
    fromVC.view.userInteractionEnabled = NO;
    if (!toVC || !fromVC) {return;}
    [self addChildViewController:toVC];
    
    CGRect toVCFrame = self.view.frame;
    toVC.view.frame = toVCFrame;
    [self.containerView addSubview:toVC.view];
    self.selectedViewControllerView = toVC.view;
    
    CGAffineTransform toVCTransformTrans = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, CGRectGetHeight(toVCFrame));
    
    toVC.view.transform = toVCTransformTrans;
    [UIView animateWithDuration:0.35 animations:^{
        toVC.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (finished) {
            [toVC didMoveToParentViewController:self];
            [self contentViewControllerDidMoveToParent:toVC];
            [self addVCToHierarchy:toVC];
            if (complete) complete();
            [self hideContentController:fromVC];
        }else{
            [self contentViewControllerDidMoveToParent:toVC];
            [toVC.view removeFromSuperview];
        }
        fromVC.view.userInteractionEnabled = YES;
    }];
}

- (void)animationDismissFromVC:(UIViewController*)fromVC toVC:(UIViewController *)toVC complete:(void(^)(void))complete{
    if (!toVC || !fromVC) return;
    fromVC.view.userInteractionEnabled = NO;
    [self addChildViewController:toVC];
    
    CGRect toVCFrame = self.view.frame;
    toVC.view.frame = toVCFrame;
    [self.containerView insertSubview:toVC.view belowSubview:fromVC.view];
    self.selectedViewControllerView = toVC.view;
    
    CGAffineTransform fromVCTransformTrans = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, CGRectGetHeight(toVCFrame));
    
    fromVC.view.transform = CGAffineTransformIdentity;
    [UIView animateWithDuration:0.35 animations:^{
        fromVC.view.transform = fromVCTransformTrans;
    } completion:^(BOOL finished) {
        if (finished) {
            [toVC didMoveToParentViewController:self];
            [self contentViewControllerDidMoveToParent:toVC];
            [self addVCToHierarchy:toVC];
            !complete?:complete();
            [self hideContentController:fromVC];
        }else{
            self.selectedViewControllerView = fromVC.view;
            [toVC.view removeFromSuperview];
        }
        fromVC.view.userInteractionEnabled = YES;
    }];
}

- (void)addVCToHierarchy:(UIViewController *)vc{
    if ([self.viewControllers containsObject:vc]) return;
    NSMutableArray *ary = [NSMutableArray arrayWithArray:self.viewControllers];
    [ary addObject:vc];
    self.viewControllers = [NSArray arrayWithArray:ary];
}


/// 内容视图约束
- (void)frameForContentController{
    if (!self.selectedViewControllerView) {return;}
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedViewControllerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedViewControllerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedViewControllerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedViewControllerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
}

@end
