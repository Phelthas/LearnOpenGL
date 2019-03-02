//
//  ViewController.m
//  Demo_OpenGLES_1
//
//  Created by kook on 2019/3/2.
//  Copyright © 2019 lxm. All rights reserved.
//

#import "ViewController.h"
#import <GLKit/GLKit.h>

@interface ViewController ()<GLKViewDelegate>

@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *effect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //1
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];
    
    //2
    self.glkView = [[GLKView alloc] initWithFrame:self.view.bounds context:self.context];
    self.glkView.delegate = self;
    [self.view addSubview:self.glkView];
    
    //3
    const GLfloat vertexArray[] = {
        0.0,  0.5,  0.0,
        -0.5, -0.5, 0,
        0.5,  -0.5, 0
    };
    
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexArray), vertexArray, GL_STATIC_DRAW);
    
    //4
    self.effect = [[GLKBaseEffect alloc] init];
    //    self.effect.constantColor = GLKVector4Make(0, 0, 1, 1);
    
    //5
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 3, (GLfloat *)NULL);
    
}


#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    //6
    glClearColor(0.5, 0, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
}

@end
