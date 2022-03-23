//
//  DemoGLGeometry.h
//  DemoUtils
//
//  Created by billthaslu on 2021/8/17.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark ----------------------------------Coordinate----------------------------------
/**
 OpenGL坐标系与UIKit坐标系不同
 OpenGL坐标系范围为[-1，1]，x向右'→'为正，y向上'→'为正；
 UIKit坐标系归一化以后范围为[0，1]，x向右'→'为正，y向下'↓'为正；
 */

/// 将[0,1]的x坐标转换为[-1, 1]坐标，公式：resultX = normalizedValue * 2 - 1
FOUNDATION_EXTERN CGFloat coordinateConvertionX(CGFloat normalizedValue);

/// 将[0,1]的y坐标转换为[-1, 1]坐标，公式：resultY = 1 - normalizedValue * 2；
FOUNDATION_EXTERN CGFloat coordinateConvertionY(CGFloat normalizedValue);


#pragma mark ----------------------------------sampling----------------------------------


FOUNDATION_EXTERN CGFloat leftXForSamplingSize(CGSize samplingSize);

FOUNDATION_EXTERN CGFloat rightXForSamplingSize(CGSize samplingSize);

FOUNDATION_EXTERN CGFloat bottomYForSamplingSize(CGSize samplingSize);

FOUNDATION_EXTERN CGFloat topYForSamplingSize(CGSize samplingSize);


@interface DemoGLGeometry : NSObject

+ (GLKVector2)topLeftForSamplingSize:(CGSize)samplingSize;

+ (GLKVector2)topRightForSamplingSize:(CGSize)samplingSize;

+ (GLKVector2)bottomLeftForSamplingSize:(CGSize)samplingSize;

+ (GLKVector2)bottomRightForSamplingSize:(CGSize)samplingSize;

@end

NS_ASSUME_NONNULL_END
