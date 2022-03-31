//
//  DemoGLMultiDrawFilter.h
//  DemoUtils
//
//  Created by lu xiaoming on 2022/3/22.
//

#import "DemoGLOutput.h"
#import "DemoGLProgram.h"
#import "DemoGLFramebuffer.h"


NS_ASSUME_NONNULL_BEGIN

@interface DemoGLMultiDrawFilter : DemoGLOutput<DemoGLInputProtocol>


@property (nonatomic, strong) DemoGLFramebuffer *firstInputFramebuffer;
@property (nonatomic, strong) DemoGLFramebuffer *secondInputFramebuffer;
@property (nonatomic, strong) DemoGLProgram *filterProgram;
@property (nonatomic, assign) GLint filterPositionAttribute;
@property (nonatomic, assign) GLint filterFisrtTextureCoordinateAttribute;
@property (nonatomic, assign) GLint filterInputTextureUniform;

- (void)setupWithBackgroundColor:(UIColor *)color;

- (void)setupWithShouldBlend:(BOOL)shouldBlend;

- (void)setupWithTexture2Frame:(CGRect)frame superViewSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
