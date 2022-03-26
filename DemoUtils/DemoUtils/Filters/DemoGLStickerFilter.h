//
//  DemoGLStickerFilter.h
//  DemoUtils
//
//  Created by lu xiaoming on 2022/3/24.
//

#import "DemoGLFilter.h"
#import "DemoGLPicture.h"


NS_ASSUME_NONNULL_BEGIN

@interface DemoGLStickerFilter : DemoGLFilter

- (instancetype)initWithGLPicture:(DemoGLPicture *)glPicture;

- (void)setupWithTexture2Frame:(CGRect)frame superViewSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
