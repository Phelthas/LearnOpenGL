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

- (void)setupWithBackgroundColor:(UIColor *)color;

- (void)setupWithShouldBlend:(BOOL)shouldBlend;

@end

NS_ASSUME_NONNULL_END
