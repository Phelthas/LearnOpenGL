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

- (void)setupWithImage:(UIImage *)image;

// 图片默认是左上角开始的，坐标系跟OpenGL纹理坐标系不同，如果originBottomLeft传YES，就在绘制的时候把方向调过来
// 如果没有在绘制的时候调转过来，就需要在设置纹理坐标的时候，将纹理坐标调转一下
- (void)setupWithCGImage:(CGImageRef)cgImage originBottomLeft:(BOOL)originBottomLeft;


- (void)processImage;


@end



#pragma mark ----------------------------------DemoGLPicture (ImageArray)----------------------------------



@interface DemoGLPicture (ImageArray)

/// 以imageArray初始化，需要手动调用setupWithNextImage才会将图片转为纹理
- (instancetype)initWithImageArray:(NSArray<UIImage *> *)imageArray;

- (void)setupWithNextImage;

- (BOOL)isUsingImageArray;

@end

NS_ASSUME_NONNULL_END
