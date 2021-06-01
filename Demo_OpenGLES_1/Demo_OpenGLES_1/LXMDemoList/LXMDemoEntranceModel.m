//
//  LXMDemoEntranceModel.m
//  Demo_OpenGLES_1
//
//  Created by billthaslu on 2021/5/31.
//  Copyright © 2021 lxm. All rights reserved.
//

#import "LXMDemoEntranceModel.h"

@implementation LXMDemoEntranceModel

+ (instancetype)entranceModelWithName:(NSString *)name {
    return [self entranceModelWithName:name desc:nil];
}

+ (instancetype)entranceModelWithName:(NSString *)name desc:(nullable NSString *)desc {
    LXMDemoEntranceModel *model = [[LXMDemoEntranceModel alloc] init];
    model.entranceName = name;
    model.desc = desc;
    [model setActionBlock:^(UINavigationController * _Nonnull nav) {
        UIViewController *viewController = [[NSClassFromString(name) alloc] init];
        viewController.title = desc;
        [nav pushViewController:viewController animated:YES];
    }];
    return model;
}

@end
