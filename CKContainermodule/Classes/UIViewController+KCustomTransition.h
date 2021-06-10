//
//  UIViewController+KCustomTransition.h
//  Theme
//
//  Created by fadil zeng on 2021/6/10.
//

#import <UIKit/UIKit.h>



@interface UIViewController (KCustomTransition)

- (void)customPresentViewController:(UIViewController *)vc complete:(void(^)(void))complete;

- (void)customDismissWithComplete:(void(^)(void))complete;

@end


