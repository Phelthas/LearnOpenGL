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
    [self.glView loadShadersWithVertexShaderFileName:@"DemoFixedPosition.vsh" fragmentShaderFileName:@"DemoWhiteColor.fsh"];
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

- (BOOL)loadShadersWithVertexShaderFileName:(NSString *)vertexShaderFileName fragmentShaderFileName:(NSString *)fragmentShaderFileName {
    BOOL result = [super loadShadersWithVertexShaderFileName:vertexShaderFileName fragmentShaderFileName:fragmentShaderFileName];
    _matrixLocation = glGetUniformLocation(_program, "projectionMatrix");
    return result;
}

- (CGFloat)screenAspectRatio {
    return self.width / self.height;
}

- (void)setupProgramAndViewport {
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
    
    // 设置顶点数组
    const GLKVector3 vertices[] = {
        GLKVector3Make(-0.5f, 0.5f, 0.0f), //topLeft
        GLKVector3Make(0.5f, 0.5f, 0.0f),  //topRight
        GLKVector3Make(-0.5f, -0.5f, 0.0f), // bottomLeft
        GLKVector3Make(0.5f, -0.5f, 0.0f),  // bottomRight
    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 传递vertices数据;3是每个顶点所占用元素个数，即这里是3个float为一个顶点
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (GLfloat *)NULL);
    glEnableVertexAttribArray(0);
    
//    GLKMatrix4 matrix = GLKMatrix4Identity;
    
    GLKMatrix4 matrix = GLKMatrix4MakeScale(1, [self screenAspectRatio], 1); // 缩放后的矩阵
    glUniformMatrix4fv(_matrixLocation, 1, GL_FALSE, (const GLfloat *)matrix.m);
    
}

- (void)displayContent {
    

    glClearColor(0.0, 0.25, 0.25f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Draw triangle
    // GL_TRIANGLE_STRIP的方式是固定的顶点顺序还绘制三角形的
    /**
     if n % 2 == 0 {
         vertex = [n-1, n-2, n]
     } else {
         vertex = [n-2, n-1, n]
     }
     即画出来的三角形一定是（v1, v0, v2）, (v1, v2, v3), (v3, v2, v4)... 这样的顺序
     */
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
}


@end
