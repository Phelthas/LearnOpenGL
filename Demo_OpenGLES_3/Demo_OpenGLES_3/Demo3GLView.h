//
//  Demo3GLView.h
//  Demo_OpenGLES_3
//
//  Created by billthaslu on 2021/9/7.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    GLKVector3 vertex;
    GLKVector2 coordinate;
} VertexAndCoordinate;

typedef enum : NSUInteger {
    ShaderAttributeIndexPosition = 0,
    ShaderAttributeIndexCoordinate,
    ShaderAttributeIndexCount,  //不实际使用，只是为了计数
} ShaderAttributeIndex;


@interface Demo3GLView : UIView {
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


- (instancetype)initWithFrame:(CGRect)frame
                 vertexShader:(const GLchar *)vertexShader
               fragmentShader:(const GLchar *)fragmentShader NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithFrame:(CGRect)frame
         vertexShaderFileName:(NSString *)vertexShaderFileName
       fragmentShaderFileName:(NSString *)fragmentShaderFileName NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// 子类可以重写，内部在link之前调用
- (void)bindAttributesIfNeeded;

/// 子类可以重写，内部在link成功之后调用
- (void)setupUniformLocationIfNeeded;

- (void)displayContent;

- (CGFloat)screenAspectRatio;

@end

NS_ASSUME_NONNULL_END
