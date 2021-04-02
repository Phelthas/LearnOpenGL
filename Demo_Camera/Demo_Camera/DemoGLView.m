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
    
    GLint attributeLocation[NUM_ATTRIBUTES] = {ATTRIB_VERTEX, ATTRIB_TEXTUREPOSITON};
    GLchar *attributeName[NUM_ATTRIBUTES] = {"position", "texturecoordinate"};
    
    
    
    return YES;
}



@end
