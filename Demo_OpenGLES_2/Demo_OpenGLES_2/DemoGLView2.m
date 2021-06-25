//
//  DemoGLView2.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/6/23.
//

#import "DemoGLView2.h"
#import "DemoGLUtility.h"


@implementation DemoGLView2

- (BOOL)initializeBuffer {
    [EAGLContext setCurrentContext:_context];
    
    glDisable(GL_DEPTH_TEST);
    
    //这两句必不可少，没有framebuffer就不会正常显示
    glGenBuffers(1, &_frameBufferHandler);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandler);
    
    glGenBuffers(1, &_renderBufferHandler);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBufferHandler);
    
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    //这里拿到的宽高是实际的分辨率，（1125*2436）单位像素，，而不是逻辑
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBufferHandler);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"error 1");
        return NO;
    }
    
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
    
    return YES;
}

- (void)displayContent {
    

    glClearColor(0.0, 0.25, 0.25f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Draw triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);

    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
}


@end
