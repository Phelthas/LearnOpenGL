//
//  LXMDeviceUtil.h
//  TEST_Temp
//
//  Created by billthaslu on 2020/9/9.
//  Copyright © 2020 billthaslu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LXMScreenSizeDefines.h"

#pragma mark ----------------------------------判断----------------------------------

#define reversedSizeFunc(size)          CGSizeMake(size.height, size.width)
#define isScreenSizeFunc(x)             CGSizeEqualToSize(kMainScreenSize, x)
#define isScreenSizeReversedFunc(x)     CGSizeEqualToSize(kMainScreenSize, reversedSizeFunc(x))
#define isScreenSizeEqualOrReversed(x)  (isScreenSizeFunc(x) || isScreenSizeReversedFunc(x))


#define isScreenSize320x480  isScreenSizeFunc(kScreenSize320x480)
#define isScreenSize320x568  isScreenSizeFunc(kScreenSize320x568)
#define isScreenSize375x667  isScreenSizeFunc(kScreenSize375x667)
#define isScreenSize414x736  isScreenSizeFunc(kScreenSize414x736)
#define isScreenSize375x812  isScreenSizeFunc(kScreenSize375x812)
#define isScreenSize414x896  isScreenSizeFunc(kScreenSize414x896)
#define isScreenSize390x844  isScreenSizeFunc(kScreenSize390x844)
#define isScreenSize428x926  isScreenSizeFunc(kScreenSize428x926)

//iPad横竖屏任意一个相等应该就算
#define isIPadScreenSize768x1024     isScreenSizeEqualOrReversed(kIPadScreenSize768x1024)
#define isIPadScreenSize834x1112     isScreenSizeEqualOrReversed(kIPadScreenSize834x1112)
#define isIPadScreenSize1024x1366    isScreenSizeEqualOrReversed(kIPadScreenSize1024x1366)
#define isIPadScreenSize834x1194     isScreenSizeEqualOrReversed(kIPadScreenSize834x1194)
#define isIPadScreenSize810x1080     isScreenSizeEqualOrReversed(kIPadScreenSize810x1080)

NS_ASSUME_NONNULL_BEGIN

@interface LXMDeviceUtil : NSObject

@end

NS_ASSUME_NONNULL_END
