//
//  DemoGLFilter.h
//  DemoUtils
//
//  Created by lu xiaoming on 2022/3/19.
//

#import "DemoGLOutput.h"
#import "DemoGLProgram.h"
#import "DemoGLTextureFrame.h"


NS_ASSUME_NONNULL_BEGIN

@interface DemoGLFilter : DemoGLOutput<DemoGLInputProtocol>

@property (nonatomic, strong) DemoGLTextureFrame *inputFramebuffer;
@property (nonatomic, strong) DemoGLProgram *filterProgram;
@property (nonatomic, assign) GLint filterPositionAttribute;
@property (nonatomic, assign) GLint filterTextureCoordinateAttribute;
@property (nonatomic, assign) GLint filterInputTextureUniform;

// 以下属性不要直接使用
@property (nonatomic, assign) CGSize inputTextureSize;
@property (nonatomic, assign) CGFloat backgroundColorRed;
@property (nonatomic, assign) CGFloat backgroundColorGreen;
@property (nonatomic, assign) CGFloat backgroundColorBlue;
@property (nonatomic, assign) CGFloat backgroundColorAlpha;
@property (nonatomic, assign) BOOL shouldBlend;

- (void)setupWithBackgroundColor:(UIColor *)color;

- (void)setupWithShouldBlend:(BOOL)shouldBlend;

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;

- (void)informTargetsAboutNewFrameAtTime:(CMTime)frameTime;

@end

NS_ASSUME_NONNULL_END
