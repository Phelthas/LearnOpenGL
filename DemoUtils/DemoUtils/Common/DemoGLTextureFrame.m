//
//  DemoGLTextureFrame.m
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import "DemoGLTextureFrame.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "DemoGLContext.h"
#import "DemoGLOutput.h"

@interface DemoGLTextureFrame ()

@property (nonatomic, assign) GLuint framebuffer;
@property (nonatomic, assign) GLuint texture;
@property (nonatomic, assign) DemoGLTextureFrameOptions textureOptions;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) CVPixelBufferRef renderTarget;
@property (nonatomic, assign) CVOpenGLESTextureRef renderTexture;


@end

@implementation DemoGLTextureFrame

- (instancetype)initWithSize:(CGSize)framebufferSize textureOptions:(DemoGLTextureFrameOptions)textureOptions onlyGenerateTexture:(BOOL)onlyGenerateTexture {
    self = [super init];
    if (self) {
        _size = framebufferSize;
        _textureOptions = textureOptions;
        if (onlyGenerateTexture) {
            [self generateTexture];
        } else {
            [self generateFramebuffer];
        }
    }
    return self;
}

- (instancetype)initWithSize:(CGSize)framebufferSize onlyGenerateTexture:(BOOL)onlyGenerateTexture {
    return [self initWithSize:framebufferSize textureOptions:[self defaultTextureOptions] onlyGenerateTexture:onlyGenerateTexture];
}

- (instancetype)initWithSize:(CGSize)framebufferSize {
    return [self initWithSize:framebufferSize onlyGenerateTexture:NO];
}

- (DemoGLTextureFrameOptions)defaultTextureOptions {
    DemoGLTextureFrameOptions defaultTextureOptions;
    defaultTextureOptions.minFilter = GL_LINEAR;
    defaultTextureOptions.magFilter = GL_LINEAR;
    defaultTextureOptions.wrapS = GL_CLAMP_TO_EDGE;
    defaultTextureOptions.wrapT = GL_CLAMP_TO_EDGE;
    defaultTextureOptions.internalFormat = GL_RGBA;
    defaultTextureOptions.format = GL_BGRA;
    defaultTextureOptions.type = GL_UNSIGNED_BYTE;
    return defaultTextureOptions;
}

- (int)width {
    return (int)_size.width;
}

- (int)height {
    return (int)_size.height;
}

- (GLuint)texture {
    return _texture;
}

- (void)activateFramebuffer {
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glViewport(0, 0, [self width], [self height]);
}

- (void)dealloc {
    // 注意!!! 这里必须要删除创建的各种buffer，否则必定内存泄露
    [self destroyFramebuffer];
}

#pragma mark - PrivateMethod

- (void)generateTexture {
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, _textureOptions.minFilter);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, _textureOptions.magFilter);
    // This is necessary for non-power-of-two textures
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _textureOptions.wrapS);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _textureOptions.wrapT);
}

- (void)generateFramebuffer {
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    if ([DemoGLContext supportsFastTextureUpload]) {
        CVOpenGLESTextureCacheRef textureCache = [DemoGLContext sharedImageProcessingContext].coreVideoTextureCache;
        CFDictionaryRef empty;
        CFMutableDictionaryRef attrs;
        empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
        
        CVReturn ret = CVPixelBufferCreate(kCFAllocatorDefault, [self width], [self height], kCVPixelFormatType_32BGRA, attrs, &_renderTarget);
        if (ret) {
            NSLog(@"FBO size: %f, %f", _size.width, _size.height);
            NSAssert(NO, @"Error at CVPixelBufferCreate %d", ret);
        }
        ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, _renderTarget, NULL, GL_TEXTURE_2D, _textureOptions.internalFormat, [self width], [self height], _textureOptions.format, _textureOptions.type, 0, &_renderTexture);
        if (ret) {
            NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", ret);
        }
        CFRelease(attrs);
        CFRelease(empty);
        _texture = CVOpenGLESTextureGetName(_renderTexture);
        glBindTexture(CVOpenGLESTextureGetTarget(_renderTexture), _texture);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _textureOptions.wrapT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _textureOptions.wrapS);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture, 0);
        
    } else {
        [self generateTexture];
        glBindTexture(GL_TEXTURE_2D, _texture);
        glTexImage2D(GL_TEXTURE_2D, 0, _textureOptions.internalFormat, [self width], [self height], 0, _textureOptions.format, _textureOptions.type, 0);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture, 0);
    }
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (GLubyte *)byteBuffer {
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

    CVPixelBufferLockBaseAddress(_renderTarget, 0);
    GLubyte *bufferBytes = CVPixelBufferGetBaseAddress(_renderTarget);
    CVPixelBufferUnlockBaseAddress(_renderTarget, 0);
    return bufferBytes;
#else
    return NULL; // TODO: do more with this on the non-texture-cache side
#endif
}

- (void)destroyFramebuffer {
    runSyncOnVideoProcessingQueue(^{
        if (self->_framebuffer) {
            glDeleteFramebuffers(1, &self->_framebuffer);
            self->_framebuffer = 0;
        }
        if ([DemoGLContext supportsFastTextureUpload]) {
            if (self->_renderTarget) {
                CFRelease(self->_renderTarget);
                self->_renderTarget = NULL;
            }
            if (self->_renderTexture) {
                CFRelease(self->_renderTexture);
                self->_renderTexture = NULL;
            }
        } else {
            glDeleteTextures(1, &self->_texture);
        }
    });
}

@end
