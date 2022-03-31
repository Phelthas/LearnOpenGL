//
//  DemoGLTwoInputFilter.h
//  DemoUtils
//
//  Created by lu xiaoming on 2022/3/21.
//

#import "DemoGLOutput.h"
#import "DemoGLProgram.h"
#import "DemoGLFramebuffer.h"


NS_ASSUME_NONNULL_BEGIN

@interface DemoGLTwoInputFilter : DemoGLOutput<DemoGLInputProtocol>


@property (nonatomic, strong) DemoGLFramebuffer *firstInputFramebuffer;
@property (nonatomic, strong) DemoGLFramebuffer *secondInputFramebuffer;
@property (nonatomic, strong) DemoGLProgram *filterProgram;
@property (nonatomic, assign) GLint filterPositionAttribute;
@property (nonatomic, assign) GLint filterFisrtTextureCoordinateAttribute;
@property (nonatomic, assign) GLint filterSecondTextureCoordinateAttribute;
@property (nonatomic, assign) GLint filterInputTextureUniform;
@property (nonatomic, assign) GLint filterInputTextureUniform2;

- (void)setupWithBackgroundColor:(UIColor *)color;

- (void)setupWithShouldBlend:(BOOL)shouldBlend;

@end

NS_ASSUME_NONNULL_END
