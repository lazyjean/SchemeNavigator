//
//  SchemeNavigator.h

//
//  Created by  on 8/28/17.
//  Copyright (c) 2017 liuzhen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;

@interface SchemeNavigator : NSObject

@property (nonatomic, copy) UIViewController *(^createController)(NSString *scheme, Class cls, NSArray<NSURLQueryItem *> *queryItems);

@property (nonatomic, copy) UIViewController *(^createWebBrowser)(NSURL *url);

+ (instancetype)sharedNavigator;

//设定scheme
- (void)setScheme:(NSString *)scheme;

//打开指定的url ddb://web?url=xxxx
- (void)openURL:(NSURL *)url;

/**
 *  注册一个映射
 *
 *  @param component addComponent
 *  @param cls    类名（构造类时，默认使用instantiate方法构造）
 */

+ (void)addComponent:(NSString *)component forClass:(Class)cls;

//如果是基于storyboard设计的类，可以使用这个方法
+ (void)addComponent:(NSString *)component storyboardName:(NSString *)storybaordName identifier:(NSString *)identifier;

/**
 *  根据component获取注册的Class，如果没有没有注册则返回nil
 *
 *  @param component component
 */
+ (Class)classForComponent:(NSString *)component;

@end
