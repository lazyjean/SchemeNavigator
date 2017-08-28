//
//  UIViewController+Navigator.m
//  Pods
//
//  Created by liuzhen on 2017/8/28.
//
//

#import "UIViewController+Navigator.h"

@import ObjectiveC.runtime;

@implementation UIViewController (Navigator)

- (void)setURLQueryItems:(NSArray<NSURLQueryItem *> *)items {

    for (NSURLQueryItem *item in items) {

        const char *keyString = [item.name UTF8String];
        id value = item.value;

        //从子类到父类，依次查找是否有指定的成员
        Class dumpClass = [self class];
        while (dumpClass) {

            unsigned int count;
            objc_property_t *propertys = class_copyPropertyList(dumpClass, &count);

            BOOL hasSet = NO;

            //设置参数支持的数据类型包括：long long, long, int, unsigned int, BOOL, NSString, NSNumber, int64_t, UInt64, NSInteger, NSUInteger
            for (int i = 0; i < count ; i++) {
                objc_property_t property = propertys[i];
                const char *name = property_getName(property);

                if (strcmp(name, keyString) == 0) {

                    //暂时先解决这个32位兼容的问题，这里应该研究一下类的成员名和属性名的关联关系
                    //变量名是属性名加下划线组成的（这个是非约对的关系）
                    char ivar_name[50];
                    memset(ivar_name, 0, sizeof(ivar_name));
                    ivar_name[0] = '_';
                    strcpy(ivar_name + 1, name);

                    //32位的机器，BOOL类型是不能通过setValue:forKey:进行转换的，这里我们手工转换一下
                    Ivar ivar = class_getInstanceVariable(dumpClass, ivar_name);
                    const char *type_coding = ivar_getTypeEncoding(ivar);

                    //对BOOL类型做特殊处理
                    if (strcmp(type_coding, @encode(BOOL)) == 0) {
                        if ([value isKindOfClass:[NSString class]]) {
                            value = @([(NSString *)value boolValue]);
                        }
                    }
                    //NSUInteger这个类型，setValue:forKey时，默认会调用unsignedLongLongValue,该方法是不存在的。
                    else if (strcmp(type_coding, @encode(unsigned long long)) == 0) {
                        if ([value isKindOfClass:[NSString class]]) {
                            value = @([(NSString *)value longLongValue]);
                        }
                    }
                    else if (strcmp(type_coding, "@\"NSURL\"") == 0) {
                        value = [NSURL URLWithString:value];
                    }

                    [self setValue:value forKey:item.name];
                    hasSet = YES;
                    break;
                }
            }

            free(propertys);

            //
            if (hasSet) {
                break;
            }
            else {
                dumpClass = [dumpClass superclass];
            }
        }
    }
}

+ (UIViewController *)findTop {

    UIWindow *window = nil;

    id delegate = [UIApplication sharedApplication].delegate;
    if ([delegate respondsToSelector:@selector(window)]) {
        window = [delegate window];
    }
    else {
        window = [UIApplication sharedApplication].keyWindow;
    }

    UIViewController *root = window.rootViewController;

    UIViewController *top = root;

    //如果是TabBar，则当前选中的为top
    if ([top isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tab = (UITabBarController *)top;
        top = [tab selectedViewController];
    }

    //如果是NavigationController，则取visibleViewController为top
    if ([top isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)top;
        top = [nav visibleViewController];
    }
    
    return top;
}


@end
