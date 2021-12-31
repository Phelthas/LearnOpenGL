//
//  Three_3ViewController.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/9/6.
//

#import "Three_3ViewController.h"

@interface Three_3ViewController ()

@end

@implementation Three_3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupGLView {
    self.glView = [[DemoGLView3_3 alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
}

@end



#pragma mark ----------------------------------DemoGLView3_3----------------------------------

#import "DemoGLUtility.h"
#import <GLKit/GLKit.h>
#import <LXMKit/LXMKit.h>

@interface DemoGLView3_3 ()

@property (nonatomic, assign) GLuint modelMatrixLocation;
@property (nonatomic, assign) GLuint viewMatrixLocation;
@property (nonatomic, assign) GLuint projectionMatrixLocation;

@end

@implementation DemoGLView3_3

- (BOOL)loadShaders {
    BOOL result = [super loadShadersWithVertexShaderFileName:@"DemoThree_3.vsh" fragmentShaderFileName:@"DemoTexturePassThrough.fsh"];
    if (result) {
        // 绑定的操作必须要在link之前进行，link成功之后生效
        GLint attributeLocation[ShaderAttributeIndexCount] = {ShaderAttributeIndexPosition, ShaderAttributeIndexCoordinate};
        GLchar *attributeName[ShaderAttributeIndexCount] = {"position", "inputCoordinate"};
            
        for (int i = 0; i < ShaderAttributeIndexCount; i++) {
            glBindAttribLocation(_program, attributeLocation[i], attributeName[i]);
        }
    }
    return result;
}

- (BOOL)linkProgram {
    BOOL result = [super linkProgram];
    if (result) {
        _modelMatrixLocation = glGetUniformLocation(_program, "modelMatrix");
        _viewMatrixLocation = glGetUniformLocation(_program, "viewMatrix");
        _projectionMatrixLocation = glGetUniformLocation(_program, "projectionMatrix");
    }
    return result;
}

- (void)setupProgramAndViewport {
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
    
    // 设置顶点数组
    const VertexAndCoordinate vertices[] = {
        {GLKVector3Make(-0.5, 0.5, 0), GLKVector2Make(0.0, 1.0)},
        {GLKVector3Make(0.5, 0.5, 0), GLKVector2Make(1.0, 1.0)},
        {GLKVector3Make(-0.5, -0.5, 0), GLKVector2Make(0.0, 0.0)},
        {GLKVector3Make(0.5, -0.5, 0), GLKVector2Make(1.0, 0.0)},
    };
    
//    const VertexAndCoordinate vertices[] = {
//        {GLKVector3Make(-0.75, 0.75, 0), GLKVector2Make(0.0, 1.0)},
//        {GLKVector3Make(-0.25, 0.75, 0), GLKVector2Make(1.0, 1.0)},
//        {GLKVector3Make(-0.75, 0.25, 0), GLKVector2Make(0.0, 0.0)},
//        {GLKVector3Make(-0.25, 0.25, 0), GLKVector2Make(1.0, 0.0)},
//    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 传递vertices数据;3是每个顶点所占用元素个数，即这里是3个float为一个顶点
    glVertexAttribPointer(ShaderAttributeIndexPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VertexAndCoordinate), offsetof(VertexAndCoordinate, vertex) + NULL);
    glEnableVertexAttribArray(ShaderAttributeIndexPosition);
    
    glVertexAttribPointer(ShaderAttributeIndexCoordinate, 2, GL_FLOAT, GL_FALSE, sizeof(VertexAndCoordinate), offsetof(VertexAndCoordinate, coordinate) + NULL);
    glEnableVertexAttribArray(ShaderAttributeIndexCoordinate);
    
    
    // 加载图片纹理
    GLKTextureInfo *textureInfo = [self textureInfoForTest];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    glUniform1i(0, 0);
    
    [self setupMatrix];
    
}

// 透视投影 还没搞明白
- (void)setupMatrix {
    // 给matrix赋值
//    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    GLKMatrix4 modelMatrix = GLKMatrix4MakeXRotation(GLKMathDegreesToRadians(-45));
    glUniformMatrix4fv(_modelMatrixLocation, 1, GL_FALSE, (const GLfloat *)modelMatrix.m);
    
//    GLKMatrix4 viewMatrix = GLKMatrix4Identity;
    GLKMatrix4 viewMatrix = GLKMatrix4MakeTranslation(0, 0, -2);
    glUniformMatrix4fv(_viewMatrixLocation, 1, GL_FALSE, (const GLfloat *)viewMatrix.m);
    
//    GLKMatrix4 projectionMatrix = GLKMatrix4Identity;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), [self screenAspectRatio], 1, 100);
    glUniformMatrix4fv(_projectionMatrixLocation, 1, GL_FALSE, (const GLfloat *)projectionMatrix.m);
    
}

- (void)setupMatrix1 {
    // 给matrix赋值
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    glUniformMatrix4fv(_modelMatrixLocation, 1, GL_FALSE, (const GLfloat *)modelMatrix.m);
    
//    GLKMatrix4 viewMatrix = GLKMatrix4Identity;
    GLKMatrix4 viewMatrix = GLKMatrix4MakeLookAt(0, 0, 2,
                                                 0, 0, 0,
                                                 0, 1, 0);
    glUniformMatrix4fv(_viewMatrixLocation, 1, GL_FALSE, (const GLfloat *)viewMatrix.m);
    
//    GLKMatrix4 projectionMatrix = GLKMatrix4Identity;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), [self screenAspectRatio], 1, 100);
    glUniformMatrix4fv(_projectionMatrixLocation, 1, GL_FALSE, (const GLfloat *)projectionMatrix.m);
    
}


// 正交投影 还没搞明白
- (void)setupMatrix2 {
    // 给matrix赋值
    GLKMatrix4 modelMatrix = GLKMatrix4MakeScale(400, 400, 1);
//    GLKMatrix4 modelMatrix = GLKMatrix4MakeXRotation(GLKMathDegreesToRadians(-45));
    glUniformMatrix4fv(_modelMatrixLocation, 1, GL_FALSE, (const GLfloat *)modelMatrix.m);
    
    GLKMatrix4 viewMatrix = GLKMatrix4Identity;
//    GLKMatrix4 viewMatrix = GLKMatrix4MakeTranslation(0, 0, -5);
    glUniformMatrix4fv(_viewMatrixLocation, 1, GL_FALSE, (const GLfloat *)viewMatrix.m);
    
//    GLKMatrix4 projectionMatrix = GLKMatrix4Identity;
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(-self.width / 2, self.width / 2, -self.height / 2, self.height / 2, -10, 10);
    glUniformMatrix4fv(_projectionMatrixLocation, 1, GL_FALSE, (const GLfloat *)projectionMatrix.m);
    
}



@end
