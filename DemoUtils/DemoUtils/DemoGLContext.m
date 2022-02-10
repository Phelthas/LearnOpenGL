//
//  DemoGLContext.m
//  DemoUtils
//
//  Created by billthaslu on 2022/2/8.
//

#import "DemoGLContext.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface DemoGLContext ()

@property (nonatomic, strong, readwrite) EAGLContext *context;
@property (nonatomic, strong) EAGLSharegroup *sharegroup;
@property (nonatomic, readwrite) CVOpenGLESTextureCacheRef coreVideoTextureCache;

@end

static void *openGLESContextQueueKey;

@implementation DemoGLContext

- (instancetype)init {
    self = [super init];
    if (self) {
        openGLESContextQueueKey = &openGLESContextQueueKey;
        _contextQueue = dispatch_queue_create("com.lxm.DemoOpenGL.ContextQueue", NULL);
        dispatch_queue_set_specific(_contextQueue, openGLESContextQueueKey, (__bridge void *)self, NULL);
    }
    return self;
}

+ (void *)contextKey {
    return openGLESContextQueueKey;
}

+ (DemoGLContext *)sharedImageProcessingContext {
    static dispatch_once_t onceToken;
    static DemoGLContext *_sharedImageProcessingContext = nil;
    dispatch_once(&onceToken, ^{
        _sharedImageProcessingContext = [[[self class] alloc] init];
    });
    return _sharedImageProcessingContext;
}

- (void)useAsCurrentContext {
    if ([EAGLContext currentContext] != self.context) {
        [EAGLContext setCurrentContext:self.context];
    }
}

+ (void)useImageProcessingContext {
    [[DemoGLContext sharedImageProcessingContext] useAsCurrentContext];
}

- (void)prensetBufferForDisplay {
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)useSharegroup:(EAGLSharegroup *)sharegroup {
    NSAssert(_context == nil, @"Unable to use a share group when the context has already been created. Call this method before you use the context for the first time.");
    
    _sharegroup = sharegroup;
}

+ (BOOL)supportsFastTextureUpload {
#if TARGET_IPHONE_SIMULATOR
    return NO;
#else
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wtautological-pointer-compare"
    return (CVOpenGLESTextureCacheCreate != NULL);
#pragma clang diagnostic pop

#endif
}

#pragma mark - Property

- (EAGLContext *)context {
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:_sharegroup];
        NSAssert(_context != nil, @"Unable to create an OpenGL ES 2.0 context");
        [EAGLContext setCurrentContext:_context];
        
        glDisable(GL_DEPTH_TEST);
    }
    return _context;
}

- (CVOpenGLESTextureCacheRef)coreVideoTextureCache {
    if (_coreVideoTextureCache == NULL) {
        CVReturn ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.context, NULL, &_coreVideoTextureCache);
        if (ret) {
            NSAssert(NO, @"Error at CVOpenGLESTextureCacheCreate %d", ret);
        }
    }
    return _coreVideoTextureCache;
}

@end
