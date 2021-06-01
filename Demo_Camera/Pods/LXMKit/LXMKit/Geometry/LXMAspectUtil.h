//
//  LXMAspectUtil.h
//  LXMKit
//
//  Created by billthaslu on 2021/5/26.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN


/// srcSize以aspectFill的方式充满dstSize时，srcSize需要缩放的比例
static inline CGFloat LXMAspectFillScale(CGSize srcSize, CGSize dstSize);

/// srcSize以aspectFit的方式充满dstSize时，srcSize需要缩放的比例
static inline CGFloat LXMAspectFitScale(CGSize srcSize, CGSize dstSize);


@interface LXMAspectUtil : NSObject

+ (CGSize)aspectFillSizeForSourceSize:(CGSize)srcSize destinationSize:(CGSize)dstSize;

+ (CGSize)aspectFitSizeForSourceSize:(CGSize)srcSize destinationSize:(CGSize)dstSize;

@end

NS_ASSUME_NONNULL_END
