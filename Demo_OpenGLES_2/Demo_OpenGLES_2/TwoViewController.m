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
    [self.view addSubview:self.glView];
}

@end




#pragma mark ----------------------------------DemoGLView2----------------------------------


#import "DemoGLUtility.h"


@implementation DemoGLView2

- (void)setupProgramAndViewport {
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
    
    // 设置顶点数组
    const GLfloat vertices[] = {
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f
    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // 给_positionSlot传递vertices数据
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (GLfloat *)NULL);
    glEnableVertexAttribArray(0);
}

- (void)displayContent {
    

    glClearColor(0.0, 0.25, 0.25f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Draw triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);

    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
}


@end
