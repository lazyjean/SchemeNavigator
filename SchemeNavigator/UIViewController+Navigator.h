//
//  UIViewController+Navigator.h
//  Pods
//
//  Created by liuzhen on 2017/8/28.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (Navigator)

+ (UIViewController *)findTop;

- (void)setURLQueryItems:(NSArray<NSURLQueryItem *> *)items;

@end
