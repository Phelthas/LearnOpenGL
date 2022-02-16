//
//  DemoGLView.m
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import "DemoGLView.h"
#import "DemoGLTextureFrame.h"
#import "DemoGLProgram.h"
#import "DemoGLOutput.h"
#import "DemoGLContext.h"
#import "DemoGLShaders.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


@interface DemoGLView ()

@property (nonatomic, strong) DemoGLTextureFrame *inputFrameBufferForDisplay;
@property (nonatomic, assign) GLuint displayFramebuffer;
@property (nonatomic, assign) GLuint displayRenderbuffer;
@property (nonatomic, strong) DemoGLProgram *displayProgram;
@property (nonatomic, assign) GLint displayPositionAttribute;
@property (nonatomic, assign) GLint displayTextureCoordinateAttribute;
@property (nonatomic, assign) GLint displayInputTextureUniform;
@property (nonatomic, assign) GLint displayRotateZMatrixUniform;
@property (nonatomic, assign) GLint backingWidth;
@property (nonatomic, assign) GLint backingHeight;
@property (nonatomic, assign) CGSize boundsSizeForFramebuffer;

@end

@implementation DemoGLView


+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.contentScaleFactor = UIScreen.mainScreen.scale;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([UIScreen instancesRespondToSelector:@selector(nativeScale)]) {
        self.contentScaleFactor = UIScreen.mainScreen.nativeScale;
    }
#endif
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = @{
        kEAGLDrawablePropertyRetainedBacking : @(NO),
        kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8
    };
    
    runSyncOnVideoProcessingQueue(^{
        [DemoGLContext useImageProcessingContext];
        self.displayProgram = [[DemoGLProgram alloc] initWithVertexShaderString:kGPUImageRotationVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
        [self.displayProgram addAttribute:@"position"];
        [self.displayProgram addAttribute:@"inputTextureCoordinate"];
        
        if (![self.displayProgram link]) {
            self.displayProgram = nil;
            NSAssert(NO, @"Filter shader link failed");
        }
        self.displayPositionAttribute = [self.displayProgram attributeIndex:@"position"];
        self.displayTextureCoordinateAttribute = [self.displayProgram attributeIndex:@"inputTextureCoordinate"];
        self.displayInputTextureUniform = [self.displayProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        self.displayRotateZMatrixUniform = [self.displayProgram uniformIndex:@"rotateZMatrix"];
        
        glEnableVertexAttribArray(self.displayPositionAttribute);
        glEnableVertexAttribArray(self.displayTextureCoordinateAttribute);
    
        [self createDisplayFramebuffer];
    });
}

- (void)createDisplayFramebuffer {
    [DemoGLContext useImageProcessingContext];
    glGenFramebuffers(1, &_displayFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _displayFramebuffer);
    
    glGenRenderbuffers(1, &_displayRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _displayRenderbuffer);
    
    [[DemoGLContext sharedImageProcessingContext].context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
    
    if (_backingWidth == 0 || _backingHeight == 0) {
        [self destroyDisplayFramebuffer];
        return;
    }
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _displayRenderbuffer);
    GLuint status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Failure with display framebuffer generation for display of size: %d, %d", _backingWidth, _backingHeight);

    self.boundsSizeForFramebuffer = self.bounds.size;
}

- (void)destroyDisplayFramebuffer {
    [DemoGLContext useImageProcessingContext];
    if (_displayFramebuffer) {
        glDeleteFramebuffers(1, &_displayFramebuffer);
        _displayFramebuffer = 0;
    }
    if (_displayRenderbuffer) {
        glDeleteRenderbuffers(1, &_displayRenderbuffer);
        _displayRenderbuffer = 0;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGSizeEqualToSize(self.bounds.size, self.boundsSizeForFramebuffer) && !CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        runSyncOnVideoProcessingQueue(^{
            [self destroyDisplayFramebuffer];
            [self createDisplayFramebuffer];
        });
    }
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    runSyncOnVideoProcessingQueue(^{
        [self destroyDisplayFramebuffer];
    });
}

- (void)setDisplayFramebuffer {
    if (!_displayFramebuffer) {
        [self createDisplayFramebuffer];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, _displayFramebuffer);
    glViewport(0, 0, _backingWidth, _backingHeight);
}

- (void)prensentFramebuffer {
    glBindRenderbuffer(GL_RENDERBUFFER, _displayRenderbuffer);
    [[DemoGLContext sharedImageProcessingContext] prensetBufferForDisplay];
}

#pragma mark - DemoGLInputProtocol

- (void)newFrameReadyAtTime:(CMTime)frameTime timimgInfo:(CMSampleTimingInfo)timimgInfo {
    runSyncOnVideoProcessingQueue(^{
        [self.displayProgram use];
        
        [self setDisplayFramebuffer];
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, [self.inputFrameBufferForDisplay texture]);
        glUniform1i(self.displayInputTextureUniform, 4);
        
        //如果使用了kGPUImageRotationVertexShaderString，要把旋转矩阵传进去，如果没有旋转，要传CATransform3DIdentity
//        CATransform3D transform = CATransform3DMakeRotation(degree / 360.0 * 2 * M_PI, 0, 0, 1);
        CATransform3D transform = CATransform3DIdentity;
        GLfloat rotateZMatrix[] = {
            transform.m11, transform.m12, transform.m13, transform.m14,
            transform.m21, transform.m22, transform.m23, transform.m24,
            transform.m31, transform.m32, transform.m33, transform.m34,
            transform.m41, transform.m42, transform.m43, transform.m44,
        };
        
        glUniformMatrix4fv(self.displayRotateZMatrixUniform, 1, 0, rotateZMatrix);
#warning testCode------------------------start
        
        static const GLfloat imageVertices[] = {
            -1.0f, -1.0f,
            1.0f, -1.0f,
            -1.0f,  1.0f,
            1.0f,  1.0f,
        };
        
        GLfloat coordinates[] = {
            0.0f, 0.0,
            1.0f, 0.0,
            0.0f, 1.0,
            1.0f, 1.0,
        };
        
        glVertexAttribPointer(self.displayPositionAttribute, 2, GL_FLOAT, 0, 0, imageVertices);
        glVertexAttribPointer(self.displayTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, coordinates);
        
#warning testCode------------------------end
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        [self prensentFramebuffer];
        
    });
}

- (void)setInputTexture:(DemoGLTextureFrame *)textureFrame {
    _inputFrameBufferForDisplay = textureFrame;
}

@end