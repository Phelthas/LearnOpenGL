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
    LXMDemoEntranceModel *model = [[LXMDemoEntranceModel alloc] init];
    model.entranceName = name;
    [model setActionBlock:^(UINavigationController * _Nonnull nav) {
        UIViewController *viewController = [[NSClassFromString(name) alloc] init];
        [nav pushViewController:viewController animated:YES];
    }];
    return model;
}

@end
