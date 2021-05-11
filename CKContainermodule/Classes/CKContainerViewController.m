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
    self.view.backgroundColor = [self colorFromHexString:@"#E6E6E8"];
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

#pragma mark - container method & api

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
    
    //follow steps without animation
    UIViewController *fromVC = self.viewControllers[fromIndex];
    [self hideContentController:fromVC];
    
    UIViewController *toVC = self.viewControllers[toIndex];
    [self displayContentController:toVC];
}

- (void)displayContentController:(UIViewController*)content {
    if (!content) {return;}
    [self addChildViewController:content];
    content.view.frame = self.view.frame;
    [self.containerView addSubview:content.view];
    self.selectedViewControllerView = content.view;
    [self frameForContentController];
    [content didMoveToParentViewController:self];
    [self contentViewControllerDidMoveToParent:content];
}

- (void)hideContentController:(UIViewController*)content {
    [content willMoveToParentViewController:nil];
    self.selectedViewControllerView = nil;
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

/// 内容视图约束
- (void)frameForContentController{
    if (!self.selectedViewControllerView) {return;}
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedViewControllerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedViewControllerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedViewControllerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.selectedViewControllerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
}

- (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    
    return [self colorWithR:((rgbValue & 0xFF0000) >> 16) G:((rgbValue & 0xFF00) >> 8) B:(rgbValue & 0xFF) A:1.0];
}

- (UIColor *)colorWithR:(CGFloat)red G:(CGFloat)green B:(CGFloat)blue A:(CGFloat)alpha
{
    return [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
}

@end
