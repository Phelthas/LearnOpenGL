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

- (instancetype)initWithCGImage:(CGImageRef)cgImage;

- (void)processImage;

@end

NS_ASSUME_NONNULL_END
