//
//  TwoViewController.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/7/25.
//

#import "TwoViewController.h"

@interface TwoViewController ()

@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setupGLView {
    self.glView = [[DemoGLView2 alloc] initWithFrame:self.view.bounds];
    [self.glView loadShadersWithVertexShaderFileName:@"DemoOnlyPosition.vsh" fragmentShaderFileName:@"DemoWhiteColor.fsh"];
    [self.view addSubview:self.glView];
}

@end




#pragma mark ----------------------------------DemoGLView2----------------------------------


#import "DemoGLUtility.h"
#import <GLKit/GLKit.h>


@implementation DemoGLView2

- (void)setupProgramAndViewport {
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
    
//    // 设置顶点数组
//    const GLfloat vertices[] = {
//        -0.75f,  0.5f, 0.0f,
//        0.75f,  0.5f, 0.0f,
//        -0.5f, -0.5f, 0.0f,
//        0.5f,  -0.5f, 0.0f
//    };
//
//    GLuint vbo;
//    glGenBuffers(1, &vbo);
//    glBindBuffer(GL_ARRAY_BUFFER, vbo);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
//
//    // 传递vertices数据;3是每个顶点所占用元素个数，即这里是3个float为一个顶点
//    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (GLfloat *)NULL);
//    glEnableVertexAttribArray(0);
    
    {
        // 设置顶点数组
        const GLKVector3 vertices[] = {
            GLKVector3Make(-0.75f, 0.5f, 0.0f),
            GLKVector3Make(0.75f, 0.5f, 0.0f),
            GLKVector3Make(-0.5f, -0.5f, 0.0f),
            GLKVector3Make(0.5f, -0.5f, 0.0f),
//            GLKVector3Make(1.0f, 1.0f, 0.0f),
        };
        /**
         // 有问题的顺序，
         const GLKVector3 vertices[] = {
             GLKVector3Make(-0.75f, 0.5f, 0.0f),
             GLKVector3Make(0.75f, 0.5f, 0.0f),
             GLKVector3Make(0.5f, -0.5f, 0.0f),
             GLKVector3Make(-0.5f, -0.5f, 0.0f),
         };
         */
        
        GLuint vbo;
        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        
        // 传递vertices数据;3是每个顶点所占用元素个数，即这里是3个float为一个顶点
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (GLfloat *)NULL);
        glEnableVertexAttribArray(0);
        
    }
    
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
