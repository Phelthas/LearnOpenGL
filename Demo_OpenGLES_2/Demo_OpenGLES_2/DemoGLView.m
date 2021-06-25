//
//  DemoGLView.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/6/16.
//

#import "DemoGLView.h"
#import "DemoGLUtility.h"

static const char * kPassThruVertex = _STRINGIFY(

attribute vec4 position;

void main()
{
    gl_Position = position;
//    gl_PointSize = 40.0;
}
                                                 
);

static const char * kPassThruFragment = _STRINGIFY(
                                                   
void main()
{
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
                                                   
);


@interface DemoGLView ()

@end

@implementation DemoGLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentScaleFactor = UIScreen.mainScreen.scale;
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        if ([UIScreen instancesRespondToSelector:@selector(nativeScale)]) {
            self.contentScaleFactor = UIScreen.mainScreen.nativeScale;
        }
#endif
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = @{
            kEAGLDrawablePropertyRetainedBacking : @(YES),
            kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8
        };
        
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!_context) {
            return nil;
        }
    }
    return self;
}


- (BOOL)loadShaders {
    [EAGLContext setCurrentContext:_context];
    
    GLuint vertexShader, fragmentShader;
    _program = glCreateProgram();
    
    
    if (![DemoGLUtility complieShader:&vertexShader type:GL_VERTEX_SHADER shaderSource:kPassThruVertex]) {
        return false;
    }
    if (![DemoGLUtility complieShader:&fragmentShader type:GL_FRAGMENT_SHADER shaderSource:kPassThruFragment]) {
        return false;
    }
    
    glAttachShader(_program, vertexShader);

    glAttachShader(_program, fragmentShader);
    
    
    if (![DemoGLUtility linkProgram:_program]) {
        if (vertexShader) {
            glDeleteShader(vertexShader);
        }
        if (fragmentShader) {
            glDeleteShader(fragmentShader);
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        return false;
    }
    
    if (vertexShader) {
        glDetachShader(_program, vertexShader);
        glDeleteShader(vertexShader);
    }
    if (fragmentShader) {
        glDetachShader(_program, fragmentShader);
        glDeleteShader(fragmentShader);
    }

    return true;
}


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
    
    return YES;
}

- (void)displayContent {
    

    glClearColor(0.0, 0.25, 0.25f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 设置顶点数组
    const GLfloat vertices[] = {
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f
    };

    // 给_positionSlot传递vertices数据
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(0);

    // Draw triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);

    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
}

@end
