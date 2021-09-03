//
//  Three_2ViewController.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/9/2.
//

#import "Three_2ViewController.h"

@interface Three_2ViewController ()

@end

@implementation Three_2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupGLView {
    self.glView = [[DemoGLView3_2 alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
}

@end



#pragma mark ----------------------------------DemoGLView3_2----------------------------------

#import "DemoGLUtility.h"
#import <GLKit/GLKit.h>

@interface DemoGLView3_2 ()

@property (nonatomic, assign) GLuint matrixLocation;

@end

@implementation DemoGLView3_2

- (BOOL)loadShaders {
    BOOL result = [super loadShadersWithVertexShaderFileName:@"DemoThree.vsh" fragmentShaderFileName:@"DemoTexturePassThrough.fsh"];
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
        _matrixLocation = glGetUniformLocation(_program, "projectionMatrix");
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
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"saber" ofType:@"jpeg"];//1280*1024
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"xianhua" ofType:@"png"];// 64*64
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

    NSDictionary *optionDict = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:image.CGImage options:optionDict error:nil];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureInfo.name);
    glUniform1i(0, 0);
    
    [self setupMatrix3];
    
}

- (void)setupMatrix1 {
    // 给matrix赋值
    GLKMatrix4 matrix = GLKMatrix4Identity;
    glUniformMatrix4fv(_matrixLocation, 1, GL_FALSE, (const GLfloat *)matrix.m);
}

- (void)setupMatrix2 {
    GLKMatrix4 matrix = GLKMatrix4MakeScale(1, [self screenAspectRatio], 1); // 缩放后的矩阵
    glUniformMatrix4fv(_matrixLocation, 1, GL_FALSE, (const GLfloat *)matrix.m);
}

- (void)setupMatrix3 {
    GLKMatrix4 matrix = GLKMatrix4MakeWithRows(GLKVector4Make(1, 0, 0, 0),
                                               GLKVector4Make(0, -1, 0, 0),
                                               GLKVector4Make(0, 0, 1, 1),
                                               GLKVector4Make(0, 0, 0, 1));
    
    glUniformMatrix4fv(_matrixLocation, 1, GL_FALSE, (const GLfloat *)matrix.m);
}


@end
