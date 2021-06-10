//
//  UIViewController+KCustomTransition.m
//  Theme
//
//  Created by fadil zeng on 2021/6/10.
//

#import "UIViewController+KCustomTransition.h"

@implementation UIViewController (KCustomTransition)

#pragma mark - tab action
- (void)customPresentViewController:(UIViewController *)vc complete:(void(^)(void))complete{
    
    UIViewController *parentVC = self.parentViewController;
    if (!parentVC) return;
    
    if (!vc) return;
    
    if (vc.parentViewController) return;
    
    Class objVC = NSClassFromString(@"CKContainerViewController");
    if (![parentVC isKindOfClass:[objVC class]]) return;
    
    SEL methodSEL = NSSelectorFromString(@"customPresentViewController:complete:");
    IMP methodIMP = [parentVC methodForSelector:methodSEL];
    void(*func)(id,SEL,id,void(^)(void)) = (void *)methodIMP;
    func(parentVC,methodSEL,vc,complete);
}

- (void)customDismissWithComplete:(void(^)(void))complete{
    UIViewController *parentVC = self.parentViewController;
    if (!parentVC) return;
    
    Class objVC = NSClassFromString(@"CKContainerViewController");
    if (![parentVC isKindOfClass:[objVC class]]) return;
    
    SEL methodSEL = NSSelectorFromString(@"customDismissViewController:complete:");
    IMP methodIMP = [parentVC methodForSelector:methodSEL];
    void(*func)(id,SEL,id,void(^)(void)) = (void *)methodIMP;
    func(parentVC,methodSEL,self,complete);
}

@end
