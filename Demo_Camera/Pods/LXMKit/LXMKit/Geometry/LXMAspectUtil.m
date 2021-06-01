//
//  LXMAspectUtil.m
//  LXMKit
//
//  Created by billthaslu on 2021/5/26.
//

#import "LXMAspectUtil.h"

/**
 对AspectFit来说，是需要长边充满目标区域，短边按原来的尺寸适配。
 所以对原图来说，srcWidth和srcHeight的比例是固定的；不确定的是原图需要放大或者缩小的系数；
 针对这个问题的计算，就涉及到两个比例：
 wScale =  dstSize.width / srcSize.width；是目标宽度与原图宽度的比值。
 hScale =  dstSize.height / srcSize.height；是目标高度与原图高度的比值。
 因为是要长边充满，所以要取wScale和hScale中较小的一个 dstScale = MIN(wScale, hScale)
 （注意：是sclae中较小的一个，而不是具体宽高中较小的，这样才能保证图片没有被剪裁）
 然后newWidth = srcSize.width * dstScale
 如果是wScale较小，那
 newWidth = srcSize.width * dstScale = srcSize.width * dstSize.width / srcSize.width = dstSize.width; 即原图宽度缩放到了目标宽度
 newHeight = srcSize.height *dstScale = srcSize.height * dstSize.width / srcSize.width ; 即原图高度按比例缩放。

 如果是hScale较小，那
 newWidth = srcSize.width * dstScale = srcSize.width * dstSize.height / srcSize.height; 即原图宽度按比例缩放；
 newHeight = srcSize.height *dstScale = srcSize.height * dstSize.height / srcSize.height = dstSize.height ; 即原图高度缩放成了目标高度

 对于AspectFill来说，是需要短边充满目标区域，长边那比例缩放，然后把长边超出的部分剪裁掉；
 因为是短边充满，所以要取所以要取wScale和hScale中较大的一个 dstScale = MAX(wScale, hScale)
 其他计算同上。
 */


/// srcSize以aspectFill的方式充满dstSize时，srcSize需要缩放的比例
static inline CGFloat LXMAspectFillScale(CGSize srcSize, CGSize dstSize) {
    return MAX(dstSize.width / srcSize.width, dstSize.height / srcSize.height);
}

/// srcSize以aspectFit的方式充满dstSize时，srcSize需要缩放的比例
static inline CGFloat LXMAspectFitScale(CGSize srcSize, CGSize dstSize) {
    return MIN(dstSize.width / srcSize.width, dstSize.height / srcSize.height);
}



@implementation LXMAspectUtil

+ (CGSize)aspectFillSizeForSourceSize:(CGSize)srcSize destinationSize:(CGSize)dstSize {
    return [self aspectSizeForType:UIViewContentModeScaleAspectFill sourceSize:srcSize destinationSize:dstSize];
}

+ (CGSize)aspectFitSizeForSourceSize:(CGSize)srcSize destinationSize:(CGSize)dstSize {
    return [self aspectSizeForType:UIViewContentModeScaleAspectFit sourceSize:srcSize destinationSize:dstSize];
}

+ (CGSize)aspectSizeForType:(UIViewContentMode)type sourceSize:(CGSize)srcSize destinationSize:(CGSize)dstSize {
    if (srcSize.width == 0 || srcSize.height == 0 || dstSize.width == 0 || dstSize.height == 0) {
        return CGSizeZero;
    }
    CGFloat scale = 0;
    if (type == UIViewContentModeScaleAspectFill) {
        scale = LXMAspectFillScale(srcSize, dstSize);
    } else if (type == UIViewContentModeScaleAspectFit) {
        scale = LXMAspectFitScale(srcSize, dstSize);
    }
    CGFloat newWidth = srcSize.width * scale;
    CGFloat newHeight = srcSize.height * scale;
    return CGSizeMake(newWidth, newHeight);
}

@end
