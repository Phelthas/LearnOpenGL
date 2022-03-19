//
//  DemoGLPicture.h
//  DemoUtils
//
//  Created by lu xiaoming on 2022/3/17.
//

#import "DemoGLOutput.h"

NS_ASSUME_NONNULL_BEGIN

@interface DemoGLPicture : DemoGLOutput

- (instancetype)initWithImage:(UIImage *)image;

// 图片默认是左上角开始的，坐标系跟OpenGL纹理坐标系不同，如果originBottomLeft传YES，就在绘制的时候把方向调过来
- (instancetype)initWithCGImage:(CGImageRef)cgImage originBottomLeft:(BOOL)originBottomLeft;

- (void)processImage;

@end

NS_ASSUME_NONNULL_END
