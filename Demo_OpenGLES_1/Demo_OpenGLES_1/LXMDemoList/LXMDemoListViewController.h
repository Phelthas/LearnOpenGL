//
//  LXMDemoListViewController.h
//  Demo_OpenGLES_1
//
//  Created by billthaslu on 2021/5/31.
//  Copyright © 2021 lxm. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class LXMDemoEntranceModel;

@interface LXMDemoListViewController : UIViewController

@property (nonatomic, strong) NSArray<LXMDemoEntranceModel *> *dataArray;

@end

NS_ASSUME_NONNULL_END
