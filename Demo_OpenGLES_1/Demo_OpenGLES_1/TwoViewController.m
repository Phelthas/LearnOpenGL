//
//  TwoViewController.m
//  Demo_OpenGLES_1
//
//  Created by billthaslu on 2021/5/31.
//  Copyright © 2021 lxm. All rights reserved.
//

#import "TwoViewController.h"
#import <GLKit/GLKit.h>


@interface TwoViewController ()<GLKViewDelegate>

@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;



@end

@implementation TwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_context];

    _glkView = [[GLKView alloc] initWithFrame:self.view.bounds context:_context];
    _glkView.delegate = self;
    [self.view addSubview:_glkView];
    
    // 这里一旦数组写错了（比如小数点写成了逗号），肉眼很难发现问题
    // 所以非常建议定义，二维，三维向量的结构体，可以极大概率避免此类问题。
//    const GLfloat vertexArray[] = {
//        0.5, 0.5, 0,
//        0.5, -0.5, 0,
//        -0.5, -0.5, 0,
//        -0.5, 0.5, 0,
//    };
    const GLKVector3 vertexArray[] = {
        {0.5, 0.5, 0},
        {0.5, -0.5, 0},
        {-0.5, -0.5, 0},
        {-0.5, 0.5, 0},
    };
    
    
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexArray), vertexArray, GL_STATIC_DRAW);
    
    // 通过 index 的排列组合可以发现：只要这几个点连线画出来是矩形就可以了，跟点的顺序无关
    const GLuint indexArray[] = {
        0, 1, 2,
//        1, 2, 3,
//        0, 3, 2,
//        2, 0, 3,
//        2, 3, 0,
//        3, 0, 2,
        3, 2, 0,
    };
    
    GLuint ebo;
    glGenBuffers(1, &ebo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indexArray), indexArray, GL_STATIC_DRAW);
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, (GLfloat *)NULL);
    
}


#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
        
    glClearColor(1, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.baseEffect prepareToDraw];
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);

}

@end
