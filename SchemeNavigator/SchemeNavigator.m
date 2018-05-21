//
//  SchemeNavigator.m

//
//  Created by  on 8/28/17.
//  Copyright (c) 2017 liuzhen. All rights reserved.
//

#import "SchemeNavigator.h"
#import "UIViewController+Navigator.h"

@import ObjectiveC.runtime;
@import UIKit;
@import SafariServices;

//添加host属性
@implementation UIBarButtonItem(SchemeNavigator)
static char HostKey;
- (UIViewController *)host {
    return objc_getAssociatedObject(self, &HostKey);
}
- (void)setHost:(UIViewController *)host {
    objc_setAssociatedObject(self, &HostKey, host, OBJC_ASSOCIATION_ASSIGN);
}
@end

@interface SchemeNavigator ()
@property (nonatomic, strong) NSMutableDictionary *classMap;
@property (nonatomic, strong) NSMutableDictionary *storyboardMap;
@property (nonatomic, strong) NSString *scheme;
@end

@implementation SchemeNavigator

+ (instancetype)sharedNavigator {
    static SchemeNavigator *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(sharedInstance == nil) {
            sharedInstance = [[SchemeNavigator alloc] init];
        }
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _classMap = [NSMutableDictionary dictionary];
        _storyboardMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (Class)classForName:(NSString *)name {

    //构造对应的控制器
    Class cls = self.classMap[name];

    //如果找不到对应的类，则使用默认页面
    if (!cls) {
        cls = self.classMap[@"default"];
    }

    return cls;
}

- (void)openURL:(NSURL *)url {

    NSAssert(url, @"openURL: url不能为nil");
    NSAssert(_scheme, @"初始化SchemeNavigator后，必须设定scheme");

    NSURLComponents *components = [self jumpURLCompoentsWithURL:url];

    if ([components.scheme isEqualToString:self.scheme]) {
        UIViewController *source = [UIViewController findTop];
        UIViewController *destination = [self createControllerWithURLComponents:components];
        [self showFrom:source to:destination];
    }
    else if ([components.scheme isEqualToString:@"http"] ||
             [components.scheme isEqualToString:@"https"]) {

        UIViewController *source = [UIViewController findTop];
        UIViewController *destination = nil;

        if (self.createWebBrowser) {
            destination = self.createWebBrowser(url);
            [self showFrom:source to:destination];
        }
        else {
            destination = [[SFSafariViewController alloc] initWithURL:url];
            [source presentViewController:destination animated:YES completion:nil];
        }
    }
    else {
        if (self.routeTo && self.routeTo(url)) {
            return;
        }
        [self routeToAppOpenURL:url];
    }
}

- (UIViewController *)createControllerWithURLComponents:(NSURLComponents *)components {

    UIViewController *vc = nil;

    Class cls = [self classForName:components.host];

    if (cls) {
        if (self.createController) {
            vc = self.createController(self.scheme, cls, components.queryItems);
        }
        if (!vc) {
            vc = [[cls alloc] init];
        }
    }
    else {
        NSString *storybaordName =  [[_storyboardMap[components.host] pathComponents] firstObject];
        NSString *identifier = [[_storyboardMap[components.host] pathComponents] lastObject];
        vc = storybaordName && identifier ? [[UIStoryboard storyboardWithName:storybaordName bundle:nil] instantiateViewControllerWithIdentifier:identifier] : nil;
    }

    NSAssert(vc, @"非法的的url地址, <host>:%@ 无法找到对应的控制器", components.host);

    [vc setURLQueryItems:components.queryItems];

    return vc;
}

//显示指定的控制器
- (void)showFrom:(UIViewController *)source to:(UIViewController *)destination {
    if (source.navigationController) {
        [source.navigationController pushViewController:destination animated:YES];
    }
    else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:destination];
        destination.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss:)];
        destination.navigationItem.leftBarButtonItem.host = destination;
        [source presentViewController:nav animated:YES completion:nil];
    }
}

- (void)dismiss:(UIBarButtonItem *)sender {
    [sender.host dismissViewControllerAnimated:YES completion:nil];
}

//构造将要最终跑转的URLComponents
- (NSURLComponents *)jumpURLCompoentsWithURL:(NSURL *)jumpURL {
    NSURLComponents *comps = [[NSURLComponents alloc] initWithURL:jumpURL resolvingAgainstBaseURL:YES];
    return comps;
}

- (void)routeToAppOpenURL:(NSURL *)url {
    if([[UIApplication sharedApplication]canOpenURL:url]) {
        [[UIApplication sharedApplication]openURL:url];
    }
}

+ (void)addComponent:(NSString *)component forClass:(Class)cls {
    NSAssert(component != nil, @"component should not nil");
    NSAssert(cls != nil, @"class should not nil");
    [[[[self class] sharedNavigator] classMap] setObject:cls forKey:[component lowercaseString]];
}

+ (void)addComponent:(NSString *)component storyboardName:(NSString *)storybaordName identifier:(NSString *)identifier {
    NSAssert(component && storybaordName && identifier, @"component, storybaordName, identifier不能为nil");
    [[[self class] sharedNavigator] storyboardMap][component] = [NSString stringWithFormat:@"%@/%@", storybaordName, identifier];
}

+ (Class)classForComponent:(NSString *)component {
    return component ? [[[self class] sharedNavigator] classMap][component] : nil;
}

@end
