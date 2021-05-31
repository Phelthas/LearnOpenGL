//
//  LXMDemoEntranceModel.h
//  Demo_OpenGLES_1
//
//  Created by billthaslu on 2021/5/31.
//  Copyright © 2021 lxm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^LXMEntranceCallback)(UINavigationController *nav);

@interface LXMDemoEntranceModel : NSObject

@property (nonatomic, copy) NSString *entranceName;
@property (nonatomic, copy) LXMEntranceCallback actionBlock;

+ (instancetype)entranceModelWithName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
