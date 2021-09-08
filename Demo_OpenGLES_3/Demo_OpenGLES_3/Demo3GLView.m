//
//  Demo3GLView.m
//  Demo_OpenGLES_3
//
//  Created by billthaslu on 2021/9/7.
//

#import "Demo3GLView.h"
#import "DemoGLUtility.h"
#import <LXMKit/LXMKit.h>

static const char * kPassThruVertex = _STRINGIFY(

attribute vec4 position;

void main()
{
    gl_Position = position;
}
                                                 
);

static const char * kPassThruFragment = _STRINGIFY(
                                                   
void main()
{
    gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
}
                                                   
);


@interface Demo3GLView ()

@end

@implementation Demo3GLView

- (void)dealloc {
    [self destroyBuffers];
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame vertexShader:kPassThruVertex fragmentShader:kPassThruFragment];
}

- (instancetype)initWithFrame:(CGRect)frame vertexShader:(const GLchar *)vertexShader fragmentShader:(const GLchar *)fragmentShader {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGLLayer];
        [self initializeBuffer];
        [self loadShadersWithVertexShaderSource:vertexShader fragmentShaderSource:fragmentShader];
        [self bindAttributesIfNeeded];
        [self linkProgram];
        [self setupUniformLocationIfNeeded];
        [self setupProgramAndViewport];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame vertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString {
    NSAssert(vertexShaderString && fragmentShaderString, @"shader 不能为nil");
    const GLchar *vertexShaderSource;
    const GLchar *fragmentShaderSource;
    vertexShaderSource = (GLchar *)[vertexShaderString UTF8String];
    fragmentShaderSource = (GLchar *)[fragmentShaderString UTF8String];
    return [self initWithFrame:frame vertexShader:vertexShaderSource fragmentShader:fragmentShaderSource];
}


/// 这个地方还没完全想好怎么样的结构最合理，先保留两个NS_DESIGNATED_INITIALIZER
- (instancetype)initWithFrame:(CGRect)frame vertexShaderFileName:(NSString *)vertexShaderFileName fragmentShaderFileName:(NSString *)fragmentShaderFileName {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupGLLayer];
        [self initializeBuffer];
        [self loadShadersWithVertexShaderFileName:vertexShaderFileName fragmentShaderFileName:fragmentShaderFileName];
        [self bindAttributesIfNeeded];
        [self linkProgram];
        [self setupUniformLocationIfNeeded];
        [self setupProgramAndViewport];
    }
    return self;
}

- (void)setupGLLayer {
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
    NSAssert(_context != nil, @"kEAGLRenderingAPIOpenGLES2 初始化失败");
    
}


- (BOOL)initializeBuffer {
    [EAGLContext setCurrentContext:_context];
    
    glDisable(GL_DEPTH_TEST);
    
    //这两句必不可少，没有framebuffer就不会正常显示
    glGenBuffers(1, &_frameBufferHandler);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandler);
    
    glGenBuffers(1, &_renderBufferHandler);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBufferHandler);
    
    // 为renderBuffer分配存储区，这里是将self.layer的绘制存储区作为renderBuffer的存储区；
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    //这里拿到的宽高是实际的分辨率，（1125*2436）单位像素，，而不是逻辑
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
    
    // 将renderBuffer绑定到frameBuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBufferHandler);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"error 1");
        return NO;
    }
    
    return YES;
}


- (BOOL)loadShadersWithVertexShaderSource:(const GLchar *)vertexShaderSource fragmentShaderSource:(const GLchar *)fragmentShaderSource {
    
    _program = glCreateProgram();
    
    if (![DemoGLUtility complieShader:&_vertexShader type:GL_VERTEX_SHADER shaderSource:vertexShaderSource]) {
        return false;
    }
    if (![DemoGLUtility complieShader:&_fragmentShader type:GL_FRAGMENT_SHADER shaderSource:fragmentShaderSource]) {
        return false;
    }
    
    return true;
}


- (BOOL)loadShadersWithVertexShaderFileName:(NSString *)vertexShaderFileName fragmentShaderFileName:(NSString *)fragmentShaderFileName {
    NSArray *vertexShaderNameArray = [vertexShaderFileName componentsSeparatedByString:@"."];
    NSAssert(vertexShaderNameArray.count == 2, @"必须传入shader的文件名");
    
    NSArray *fragmentShaderNameArray = [fragmentShaderFileName componentsSeparatedByString:@"."];
    NSAssert(fragmentShaderNameArray.count == 2, @"必须传入shader的文件名");
    
    _program = glCreateProgram();
    
    if (![DemoGLUtility complieShader:&_vertexShader type:GL_VERTEX_SHADER shaderFileName:vertexShaderNameArray[0] shaderExtension:vertexShaderNameArray[1]]) {
        return false;
    }

    if (![DemoGLUtility complieShader:&_fragmentShader type:GL_FRAGMENT_SHADER shaderFileName:fragmentShaderNameArray[0] shaderExtension:fragmentShaderNameArray[1]]) {
        return false;
    }

    return true;
}

- (void)bindAttributesIfNeeded {
    
}

- (BOOL)linkProgram {
    
    glAttachShader(_program, _vertexShader);

    glAttachShader(_program, _fragmentShader);
    
    if (![DemoGLUtility linkProgram:_program]) {
        if (_vertexShader) {
            glDeleteShader(_vertexShader);
        }
        if (_fragmentShader) {
            glDeleteShader(_fragmentShader);
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        return false;
    }
    
    if (_vertexShader) {
        glDetachShader(_program, _vertexShader);
        glDeleteShader(_vertexShader);
    }
    if (_fragmentShader) {
        glDetachShader(_program, _fragmentShader);
        glDeleteShader(_fragmentShader);
    }
    return true;
}

- (void)setupUniformLocationIfNeeded {
    
}

- (void)setupProgramAndViewport {
    
    glUseProgram(_program);
    
    glViewport(0, 0, _width, _height);
}

- (void)displayContent {
    

    glClearColor(0.0, 0.25, 0.25f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    /**
     注意!!!
     这里没有使用vbo，是直接用glVertexAttribPointer函数将数据传递过去的
     写在其他地方会crash，暂时还不知道为啥
     */
    // 设置顶点数组
    const GLfloat vertices[] = {
        0.0f,  0.5f, 0.0f,
        -0.5f, -0.5f, 0.0f,
        0.5f,  -0.5f, 0.0f
    };
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(0);
    
    // Draw triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);

    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
}

- (void)destroyBuffers {
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;//这一句理论上不能少，需要手动置0，否则其他地方判断可能会出错
    }
    if (_frameBufferHandler) {
        glDeleteBuffers(1, &_frameBufferHandler);
        _frameBufferHandler = 0;//这一句理论上不能少，需要手动置0，否则其他地方判断可能会出错
    }
    if (_renderBufferHandler) {
        glDeleteBuffers(1, &_renderBufferHandler);
        _renderBufferHandler = 0;//这一句理论上不能少，需要手动置0，否则其他地方判断可能会出错
    }
    if ([EAGLContext currentContext] == _context) {
        // 这一句很关键，否则_context不会释放，会占用很多内存
        [EAGLContext setCurrentContext:nil];
    }
}


#pragma mark -

- (CGFloat)screenAspectRatio {
    return self.width / self.height;
}

@end
