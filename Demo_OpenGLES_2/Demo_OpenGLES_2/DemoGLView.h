//
//  DemoGLView.h
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/6/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoGLView : UIView {
    //实例变量如果没有显式的声明出来，子类就不能直接用
    EAGLContext *_context;
    GLuint _program;
    GLuint _frameBufferHandler;
    GLuint _renderBufferHandler;
    GLint _width;
    GLint _height;
}

//@property (nonatomic, strong) EAGLContext *context;
//@property (nonatomic, assign) GLuint program;
//@property (nonatomic, assign) GLuint frameBufferHandler;
//@property (nonatomic, assign) GLuint renderBufferHandler;
//@property (nonatomic, assign) GLint width;
//@property (nonatomic, assign) GLint height;

- (BOOL)loadShaders;

- (BOOL)loadShadersWithVertexShaderSource:(const GLchar *)vertexShaderSource fragmentShaderSource:(const GLchar *)fragmentShaderSource;

- (BOOL)loadShadersWithVertexShaderFileName:(NSString *)vertexShaderFileName fragmentShaderFileName:(NSString *)fragmentShaderFileName;

- (void)setupProgramAndViewport;

- (void)displayContent;

@end

NS_ASSUME_NONNULL_END
