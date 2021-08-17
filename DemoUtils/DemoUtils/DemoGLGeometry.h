//
//  DemoGLGeometry.h
//  DemoUtils
//
//  Created by billthaslu on 2021/8/17.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

CGFloat leftXForSamplingSize(CGSize samplingSize);

CGFloat rightXForSamplingSize(CGSize samplingSize);

CGFloat bottomYForSamplingSize(CGSize samplingSize);

CGFloat topYForSamplingSize(CGSize samplingSize);


@interface DemoGLGeometry : NSObject

+ (GLKVector2)topLeftForSamplingSize:(CGSize)samplingSize;

+ (GLKVector2)topRightForSamplingSize:(CGSize)samplingSize;

+ (GLKVector2)bottomLeftForSamplingSize:(CGSize)samplingSize;

+ (GLKVector2)bottomRightForSamplingSize:(CGSize)samplingSize;

@end

NS_ASSUME_NONNULL_END
