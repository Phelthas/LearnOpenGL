//
//  DemoGLView.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/6/16.
//

#import "DemoGLView.h"
#import "DemoGLUtility.h"

#if !defined(_STRINGIFY)
#define __STRINGIFY( _x )   # _x
#define _STRINGIFY( _x )   __STRINGIFY( _x )
#endif

static const char * kPassThruVertex = _STRINGIFY(

attribute vec4 position;

void main()
{
    gl_Position = position;
    gl_PointSize = 40.0;
}
                                                 
);

static const char * kPassThruFragment = _STRINGIFY(
                                                   
void main()
{
    gl_FragColor = vec4(1.0, 0.0, 1.0, 1.0);
}
                                                   
);


@interface DemoGLView ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLuint frameBufferHandler;
@property (nonatomic, assign) GLuint renderBufferHandler;
@property (nonatomic, assign) GLint width;
@property (nonatomic, assign) GLint height;

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
    [EAGLContext setCurrentContext:self.context];
    
    GLuint vertexShader, fragmentShader;
    self.program = glCreateProgram();
    
    
    if (![DemoGLUtility complieShader:&vertexShader type:GL_VERTEX_SHADER shaderSource:kPassThruVertex]) {
        return false;
    }
    if (![DemoGLUtility complieShader:&fragmentShader type:GL_FRAGMENT_SHADER shaderSource:kPassThruFragment]) {
        return false;
    }
    
    glAttachShader(self.program, vertexShader);

    glAttachShader(self.program, fragmentShader);
    
    
    if (![DemoGLUtility linkProgram:self.program]) {
        if (vertexShader) {
            glDeleteShader(vertexShader);
        }
        if (fragmentShader) {
            glDeleteShader(fragmentShader);
        }
        if (self.program) {
            glDeleteProgram(self.program);
            self.program = 0;
        }
        return false;
    }
    
    if (vertexShader) {
        glDetachShader(self.program, vertexShader);
        glDeleteShader(vertexShader);
    }
    if (fragmentShader) {
        glDetachShader(self.program, fragmentShader);
        glDeleteShader(fragmentShader);
    }

    return true;
}


- (BOOL)initializeBuffer {
    [EAGLContext setCurrentContext:_context];
    
    glDisable(GL_DEPTH_TEST);
    
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
    
    return YES;
}

- (void)displayContent {
    glUseProgram(self.program);
    
    glViewport(0, 0, _width, _height);

    glClearColor(0.0, 0.25, 0.25f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
//
//    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
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
    glDrawArrays(GL_POINTS, 0, 3);

    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
}

@end
