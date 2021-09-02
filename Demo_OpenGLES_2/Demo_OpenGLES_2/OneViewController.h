//
//  OneViewController.h
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/6/14.
//

#import <UIKit/UIKit.h>
#import "DemoLogDefines.h"
#import "DemoCommon.h"

NS_ASSUME_NONNULL_BEGIN

@class DemoGLView;

@interface OneViewController : UIViewController

@property (nonatomic, strong) DemoGLView *glView;

/// 子类可重载，会在ViewDidLoad中调用
- (void)setupGLView;

@end

#pragma mark ----------------------------------DemoGLView----------------------------------

@interface DemoGLView : UIView {
    //实例变量如果没有显式的声明出来，子类就不能直接用
    EAGLContext *_context;
    GLuint _program;
    GLuint _frameBufferHandler;
    GLuint _renderBufferHandler;
    GLint _width;
    GLint _height;
    
    GLuint _vertexShader;
    GLuint _fragmentShader;
}

//@property (nonatomic, strong) EAGLContext *context;
//@property (nonatomic, assign) GLuint program;
//@property (nonatomic, assign) GLuint frameBufferHandler;
//@property (nonatomic, assign) GLuint renderBufferHandler;
//@property (nonatomic, assign) GLint width;
//@property (nonatomic, assign) GLint height;

- (CGFloat)screenAspectRatio;

- (BOOL)loadShaders;

- (BOOL)loadShadersWithVertexShaderSource:(const GLchar *)vertexShaderSource fragmentShaderSource:(const GLchar *)fragmentShaderSource;

- (BOOL)loadShadersWithVertexShaderFileName:(NSString *)vertexShaderFileName fragmentShaderFileName:(NSString *)fragmentShaderFileName;

- (BOOL)linkProgram;

- (void)setupProgramAndViewport;

- (void)displayContent;

@end

NS_ASSUME_NONNULL_END
