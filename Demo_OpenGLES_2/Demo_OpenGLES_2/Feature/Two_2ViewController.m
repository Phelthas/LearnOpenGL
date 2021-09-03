//
//  Two_2ViewController.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/8/31.
//

#import "Two_2ViewController.h"

@interface Two_2ViewController ()

@end

@implementation Two_2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupGLView {
    self.glView = [[DemoGLView2_2 alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.glView];
}


@end


#pragma mark ----------------------------------DemoGLView2_2----------------------------------


#import "DemoGLUtility.h"
#import <GLKit/GLKit.h>
#import <LXMKit/LXMKit.h>

@interface DemoGLView2_2 ()

@property (nonatomic, assign) GLuint matrixLocation;

@end

@implementation DemoGLView2_2

- (BOOL)loadShaders {
    BOOL result = [super loadShadersWithVertexShaderFileName:@"DemoFixedPosition.vsh" fragmentShaderFileName:@"DemoWhiteColor.fsh"];
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
    [self setupProgramAndViewport1];
}

- (void)setupProgramAndViewport1 {
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
    
//    // 设置顶点数组
//    const GLKVector3 vertices[] = {
//        GLKVector3Make(-0.5f, 0.5f, 0.0f), //topLeft
//        GLKVector3Make(0.5f, 0.5f, 0.0f),  //topRight
//        GLKVector3Make(-0.5f, -0.5f, 0.0f), // bottomLeft
//        GLKVector3Make(0.5f, -0.5f, 0.0f),  // bottomRight
//    };
    
    // 设置顶点数组
    const GLKVector3 vertices[] = {
        GLKVector3Make(-0.75f, 0.75f, 0.0f), //topLeft
        GLKVector3Make(-0.25f, 0.75f, 0.0f),  //topRight
        GLKVector3Make(-0.75f, 0.25f, 0.0f), // bottomLeft
        GLKVector3Make(-0.25f, 0.25f, 0.0f),  // bottomRight
    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 传递vertices数据;3是每个顶点所占用元素个数，即这里是3个float为一个顶点
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (GLfloat *)NULL);
    glEnableVertexAttribArray(0);
    
    [self setupMatrix];
    
}

- (void)setupMatrix {
    //    GLKMatrix4 matrix = GLKMatrix4Identity;
        
        GLKMatrix4 matrix = GLKMatrix4MakeScale(1, [self screenAspectRatio], 1); // 缩放后的矩阵
        matrix = GLKMatrix4Translate(matrix, 0, 0.5, 0);
        glUniformMatrix4fv(_matrixLocation, 1, GL_FALSE, (const GLfloat *)matrix.m);
}

- (void)setupMatrix2 {
   
    GLKMatrix4 matrix = GLKMatrix4MakeWithRows(GLKVector4Make(1, 0, 0, 0),
                                               GLKVector4Make(0, -1, 0, 0),
                                               GLKVector4Make(0, 0, 1, 1),
                                               GLKVector4Make(0, 0, 0, 1));
    
    
    glUniformMatrix4fv(_matrixLocation, 1, GL_FALSE, (const GLfloat *)matrix.m);
    
}


@end
