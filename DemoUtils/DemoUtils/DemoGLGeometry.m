//
//  DemoGLGeometry.m
//  DemoUtils
//
//  Created by billthaslu on 2021/8/17.
//

#import "DemoGLGeometry.h"

CGFloat leftXForSamplingSize(CGSize samplingSize) {
    return (1 - samplingSize.width) / 2;
}

CGFloat rightXForSamplingSize(CGSize samplingSize) {
    // 计算公式是： 1 - (1 - samplingSize.width) / 2,简化成下面的写法
    return (1 + samplingSize.width) / 2;
}

CGFloat bottomYForSamplingSize(CGSize samplingSize) {
    return (1 - samplingSize.height) / 2;
}

CGFloat topYForSamplingSize(CGSize samplingSize) {
    // 计算公式是： 1 - (1 - samplingSize.height) / 2,简化成下面的写法
    return (1 + samplingSize.height) / 2;
}

@implementation DemoGLGeometry

+ (GLKVector2)topLeftForSamplingSize:(CGSize)samplingSize {
    NSAssert((samplingSize.width <= 1 || samplingSize.height <= 1 ), @"samplingSize should be less than 1.0");
    return GLKVector2Make(leftXForSamplingSize(samplingSize), topYForSamplingSize(samplingSize));
}

+ (GLKVector2)topRightForSamplingSize:(CGSize)samplingSize {
    NSAssert((samplingSize.width <= 1 || samplingSize.height <= 1 ), @"samplingSize should be less than 1.0");
    return GLKVector2Make(rightXForSamplingSize(samplingSize), topYForSamplingSize(samplingSize));
}

+ (GLKVector2)bottomLeftForSamplingSize:(CGSize)samplingSize {
    NSAssert((samplingSize.width <= 1 || samplingSize.height <= 1 ), @"samplingSize should be less than 1.0");
    return GLKVector2Make(leftXForSamplingSize(samplingSize), bottomYForSamplingSize(samplingSize));
}

+ (GLKVector2)bottomRightForSamplingSize:(CGSize)samplingSize {
    NSAssert((samplingSize.width <= 1 || samplingSize.height <= 1 ), @"samplingSize should be less than 1.0");
    return GLKVector2Make(rightXForSamplingSize(samplingSize), bottomYForSamplingSize(samplingSize));
}


@end
