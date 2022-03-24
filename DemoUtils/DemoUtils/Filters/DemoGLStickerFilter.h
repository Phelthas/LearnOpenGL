//
//  DemoGLStickerFilter.h
//  DemoUtils
//
//  Created by lu xiaoming on 2022/3/24.
//

#import "DemoGLOutput.h"
#import "DemoGLProgram.h"
#import "DemoGLTextureFrame.h"
#import "DemoGLPicture.h"


NS_ASSUME_NONNULL_BEGIN

@interface DemoGLStickerFilter : DemoGLOutput<DemoGLInputProtocol>

@property (nonatomic, strong) DemoGLTextureFrame *inputFramebuffer;
@property (nonatomic, strong) DemoGLProgram *filterProgram;
@property (nonatomic, assign) GLint filterPositionAttribute;
@property (nonatomic, assign) GLint filterTextureCoordinateAttribute;
@property (nonatomic, assign) GLint filterInputTextureUniform;

- (instancetype)initWithGLPicture:(DemoGLPicture *)glPicture;

- (void)setupWithBackgroundColor:(UIColor *)color;

- (void)setupWithShouldBlend:(BOOL)shouldBlend;

- (void)setupWithTexture2Frame:(CGRect)frame superViewSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
