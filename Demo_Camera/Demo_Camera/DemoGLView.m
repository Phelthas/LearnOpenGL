//
//  DemoGLView.m
//  Demo_Camera
//
//  Created by billthaslu on 2021/4/2.
//

#import "DemoGLView.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "DemoGLUtility.h"


#if !defined(_STRINGIFY)
#define __STRINGIFY( _x )   # _x
#define _STRINGIFY( _x )   __STRINGIFY( _x )
#endif

static const char * kPassThruVertex = _STRINGIFY(

attribute vec4 position;
attribute mediump vec4 texturecoordinate;
varying mediump vec2 coordinate;

void main()
{
    gl_Position = position;
    coordinate = texturecoordinate.xy;
}
                                                 
);

static const char * kPassThruFragment = _STRINGIFY(
                                                   
varying highp vec2 coordinate;
uniform sampler2D videoframe;

void main()
{
    gl_FragColor = texture2D(videoframe, coordinate);
}
                                                   
);

enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXTUREPOSITON,
    NUM_ATTRIBUTES
};

@interface DemoGLView ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, assign) GLuint frameBufferHandler;
@property (nonatomic, assign) GLuint renderBufferHandler;
@property (nonatomic, assign) GLint width;
@property (nonatomic, assign) GLint height;
@property (nonatomic, assign) CVOpenGLESTextureCacheRef textureCache;
@property (nonatomic, assign) GLuint program;
@property (nonatomic, assign) GLint videoFrame;


@end

@implementation DemoGLView

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // On iOS8 and later we use the native scale of the screen as our content scale factor.
        // This allows us to render to the exact pixel resolution of the screen which avoids additional scaling and GPU rendering work.
        // For example the iPhone 6 Plus appears to UIKit as a 736 x 414 pt screen with a 3x scale factor (2208 x 1242 virtual pixels).
        // But the native pixel dimensions are actually 1920 x 1080.
        // Since we are streaming 1080p buffers from the camera we can render to the iPhone 6 Plus screen at 1:1 with no additional scaling if we set everything up correctly.
        // Using the native scale of the screen also allows us to render at full quality when using the display zoom feature on iPhone 6/6 Plus.
        
        self.contentScaleFactor = [UIScreen mainScreen].scale;
        // Only try to compile this code if we are using the 8.0 or later SDK.
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        if ([UIScreen instancesRespondToSelector:@selector(nativeScale)]) {
            self.contentScaleFactor = [UIScreen mainScreen].nativeScale;
        }
#endif
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking : @(NO),
                                         kEAGLDrawablePropertyColorFormat :kEAGLColorFormatRGBA8
        };
        
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!_context) {
            return nil;
        }
    }
    return self;
}

- (BOOL)initializeBuffer {
    [EAGLContext setCurrentContext:_context];
    
    glDisable(GL_DEPTH_TEST);
    
    glGenBuffers(1, &_frameBufferHandler);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandler);
    
    glGenBuffers(1, &_renderBufferHandler);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBufferHandler);
    
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBufferHandler);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"error 1");
        return NO;
    }
    
    CVReturn ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_textureCache);
    if (ret != kCVReturnSuccess) {
        NSLog(@"error %d", ret);
        return NO;
    }
    
    _videoFrame = glGetUniformLocation(self.program, "videoframe");
    
    return YES;
}


- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    static const GLfloat squareVertex[] = {
        -1.0f, -1.0f, //bottom left
        1.0f, -1.0f, //bottom right
        -1.0, 1.0f,  //top left
        1.0f, 1.0f,  //top right
    };
    if (!pixelBuffer) {
        NSLog(@"null pixelBuffer");
        return;
    }
    
    EAGLContext *oldContext = [EAGLContext currentContext];
    if (oldContext != _context) {
        if (![EAGLContext setCurrentContext:_context]) {
            NSLog(@"error with context");
            return;
        }
    }
    
    if (!_frameBufferHandler) {
        NSLog(@"error with buffers");
        return;
    }
    
    size_t frameWidth = CVPixelBufferGetWidth(pixelBuffer);
    size_t frameHeight = CVPixelBufferGetHeight(pixelBuffer);
    
    CVOpenGLESTextureRef texture = NULL;
    CVReturn error = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                  _textureCache,
                                                                  pixelBuffer,
                                                                  NULL,
                                                                  GL_TEXTURE_2D,
                                                                  GL_RGBA,
                                                                  (GLsizei)frameWidth,
                                                                  (GLsizei)frameHeight,
                                                                  GL_BGRA,
                                                                  GL_UNSIGNED_BYTE,
                                                                  0,
                                                                  &texture);
    if (!texture || error) {
        NSLog(@"error with CVOpenGLESTextureCacheCreateTextureFromImage");
        return;
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBufferHandler);
    glViewport(0, 0, _width, _height);
    
    glUseProgram(self.program);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(CVOpenGLESTextureGetTarget(texture), CVOpenGLESTextureGetName(texture));
    glUniform1i(_videoFrame, 0);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertex);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    
    // Preserve aspect ratio; fill layer bounds
    CGSize textureSamplingSize;
    CGSize cropScaleAmount = CGSizeMake( self.bounds.size.width / (float)frameWidth, self.bounds.size.height / (float)frameHeight );
    if ( cropScaleAmount.height > cropScaleAmount.width ) {
        textureSamplingSize.width = self.bounds.size.width / ( frameWidth * cropScaleAmount.height );
        textureSamplingSize.height = 1.0;
    }
    else {
        textureSamplingSize.width = 1.0;
        textureSamplingSize.height = self.bounds.size.height / ( frameHeight * cropScaleAmount.width );
    }
    
    // Perform a vertical flip by swapping the top left and the bottom left coordinate.
    // CVPixelBuffers have a top left origin and OpenGL has a bottom left origin.
    GLfloat passThroughTextureVertices[] = {
        ( 1.0 - textureSamplingSize.width ) / 2.0, ( 1.0 + textureSamplingSize.height ) / 2.0, // top left
        ( 1.0 + textureSamplingSize.width ) / 2.0, ( 1.0 + textureSamplingSize.height ) / 2.0, // top right
        ( 1.0 - textureSamplingSize.width ) / 2.0, ( 1.0 - textureSamplingSize.height ) / 2.0, // bottom left
        ( 1.0 + textureSamplingSize.width ) / 2.0, ( 1.0 - textureSamplingSize.height ) / 2.0, // bottom right
    };
    
    glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, passThroughTextureVertices);
    glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBufferHandler);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    glBindTexture(CVOpenGLESTextureGetTarget(texture), 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    CFRelease(texture);
    
    if (oldContext != _context) {
        [EAGLContext setCurrentContext:_context];
    }
    
    
}



#pragma mark -

- (BOOL)loadShaders {
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
    

    GLint attributeLocation[NUM_ATTRIBUTES] = {ATTRIB_VERTEX, ATTRIB_TEXTUREPOSITON};
    GLchar *attributeName[NUM_ATTRIBUTES] = {"position", "texturecoordinate"};
        
    for (int i = 0; i < NUM_ATTRIBUTES; i++) {
        glBindAttribLocation(self.program, attributeLocation[i], attributeName[i]);
    }
    
    
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

@end
