//
//  DemoGLi420Camera.m
//  Demo_OpenGLES_5
//
//  Created by billthaslu on 2022/3/3.
//

#import "DemoGLI420Camera.h"
#import "DemoGLShaders.h"
#import "DemoGLProgram.h"
#import "DemoGLCapturePipline.h"
#import "DemoGLContext.h"
#import "DemoGLFramebuffer.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "libyuv.h"

@interface DemoGLI420Camera ()<DemoGLCapturePiplineDelegate>

@property (nonatomic, strong) dispatch_semaphore_t frameRenderingSemaphore;
@property (nonatomic, strong) DemoGLProgram *yuvConversionProgram;
@property (nonatomic, assign) GLint yuvConversionPositionAttribute;
@property (nonatomic, assign) GLint yuvConversionTextureCoordinateAttribute;
@property (nonatomic, assign) GLint yuvConversionYTextureUniform;
@property (nonatomic, assign) GLint yuvConversionUTextureUniform;
@property (nonatomic, assign) GLint yuvConversionVTextureUniform;
@property (nonatomic, assign) GLint yuvConversionMatrixUniform;
@property (nonatomic, assign) const GLfloat *preferredConversion;
@property (nonatomic, assign) int imageBufferWidth;
@property (nonatomic, assign) int imageBufferHeight;
@property (nonatomic, assign) GLuint yTexture;
@property (nonatomic, assign) GLuint uTexture;
@property (nonatomic, assign) GLuint vTexture;

@end


@implementation DemoGLI420Camera

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition {
    self = [super initWithCameraPosition:cameraPosition];
    if (self) {
        _frameRenderingSemaphore = dispatch_semaphore_create(1);
        _preferredConversion = kColorConversion709;
        
        runSyncOnVideoProcessingQueue(^{
            [DemoGLContext useImageProcessingContext];
            if (self.capturePipline.isFullYUVRange) {
                self.yuvConversionProgram = [[DemoGLProgram alloc] initWithVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImageYUVFullRangeConversionForI420ShaderString];
            } else {
                //todo
            }
            [self.yuvConversionProgram addAttribute:@"position"];
            [self.yuvConversionProgram addAttribute:@"inputTextureCoordinate"];
            if (![self.yuvConversionProgram link]) {
                self.yuvConversionProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
            self.yuvConversionPositionAttribute = [self.yuvConversionProgram attributeIndex:@"position"];
            self.yuvConversionTextureCoordinateAttribute = [self.yuvConversionProgram attributeIndex:@"inputTextureCoordinate"];
            self.yuvConversionYTextureUniform = [self.yuvConversionProgram uniformIndex:@"yTexture"];
            self.yuvConversionUTextureUniform = [self.yuvConversionProgram uniformIndex:@"uTexture"];
            self.yuvConversionVTextureUniform = [self.yuvConversionProgram uniformIndex:@"vTexture"];
            self.yuvConversionMatrixUniform = [self.yuvConversionProgram uniformIndex:@"colorConversionMatrix"];
                        
            glEnableVertexAttribArray(self.yuvConversionPositionAttribute);
            glEnableVertexAttribArray(self.yuvConversionTextureCoordinateAttribute);
            
        });
    }
    return self;
}


- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    // The caller does not own the returned dataBuffer
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFTypeRef colorAttachments = CVBufferGetAttachment(imageBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
    if (colorAttachments != NULL) {
        if (CFStringCompare(colorAttachments, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo) {
            if (self.capturePipline.isFullYUVRange) {
                self.preferredConversion = kColorConversion601FullRange;
            } else {
                self.preferredConversion = kColorConversion601;
            }
        } else {
            self.preferredConversion = kColorConversion709;
        }
    }
    else {
        if (self.capturePipline.isFullYUVRange) {
            self.preferredConversion = kColorConversion601FullRange;
        } else {
            self.preferredConversion = kColorConversion601;
        }
    }
    CVImageBufferRef cameraFrame = [self i420PixelBufferFromSampleBuffer:sampleBuffer];

    int bufferWidth = (int)CVPixelBufferGetWidth(cameraFrame);
    int bufferHeight = (int)CVPixelBufferGetHeight(cameraFrame);
    
    
    CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    CMSampleTimingInfo timimgInfo = kCMTimingInfoInvalid;
    CMSampleBufferGetSampleTimingInfo(sampleBuffer, 0, &timimgInfo);
    [DemoGLContext useImageProcessingContext];
    
    CVOpenGLESTextureRef yTextureRef = NULL;
    CVOpenGLESTextureRef uTextureRef = NULL;
    CVOpenGLESTextureRef vTextureRef = NULL;
    if (CVPixelBufferGetPlaneCount(cameraFrame) > 0) {// Check for YUV planar inputs to do RGB conversion
        CVPixelBufferLockBaseAddress(cameraFrame, 0);
        if (self.imageBufferWidth != bufferWidth || self.imageBufferHeight != bufferHeight) {
            self.imageBufferWidth = bufferWidth;
            self.imageBufferHeight = bufferHeight;
        }
        CVOpenGLESTextureCacheRef textureCache = [DemoGLContext sharedImageProcessingContext].coreVideoTextureCache;
        
        CVReturn ret;
        //Y-plane
        glActiveTexture(GL_TEXTURE4);
        ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, cameraFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth, bufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &yTextureRef);
        if (ret) {
            //测试表明：创建一个3Plane的CVImageBufferRef然后在这里创建纹理，会报错kCVReturnPixelBufferNotOpenGLCompatible；
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", ret);
        }
        self.yTexture = CVOpenGLESTextureGetName(yTextureRef);
        glBindTexture(GL_TEXTURE_2D, self.yTexture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        //U-plane
        glActiveTexture(GL_TEXTURE5);
        ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, cameraFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth / 2, bufferHeight / 2, GL_LUMINANCE, GL_UNSIGNED_BYTE, 1, &uTextureRef);
        if (ret) {
            //测试表明：创建一个3Plane的CVImageBufferRef然后在这里创建纹理，会报错kCVReturnPixelBufferNotOpenGLCompatible；
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", ret);
        }
        self.uTexture = CVOpenGLESTextureGetName(uTextureRef);
        glBindTexture(GL_TEXTURE_2D, self.uTexture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        //V-plane
        glActiveTexture(GL_TEXTURE6);
        ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, cameraFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth / 2, bufferHeight / 2, GL_LUMINANCE, GL_UNSIGNED_BYTE, 2, &vTextureRef);
        if (ret) {
            //测试表明：创建一个3Plane的CVImageBufferRef然后在这里创建纹理，会报错kCVReturnPixelBufferNotOpenGLCompatible；
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", ret);
        }
        self.vTexture = CVOpenGLESTextureGetName(vTextureRef);
        glBindTexture(GL_TEXTURE_2D, self.vTexture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        [self convertI420toRGBoutput];
        
        CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
        CFRelease(yTextureRef);
        CFRelease(uTextureRef);
        CFRelease(vTextureRef);
        
        for (int i = 0; i < self.targets.count; i++) {
            id<DemoGLInputProtocol> target = self.targets[i];
            NSInteger textureIndex = [self.targetTextureIndices[i] integerValue];
            [target setInputFramebuffer:self.outputFramebuffer atIndex:textureIndex];
            [target setInputTextureSize:CGSizeMake(self.imageBufferWidth, self.imageBufferHeight) atIndex:textureIndex];
            [target newFrameReadyAtTime:currentTime timimgInfo:timimgInfo];
        }
        
    }
    else {
        // TODO: Mesh this with the output framebuffer structure
        // GPUImage 也没做处理
    }
    
}

- (void)convertI420toRGBoutput {
    [DemoGLContext useImageProcessingContext];
    [self.yuvConversionProgram use];
    
    if (!self.outputFramebuffer) {
        self.outputFramebuffer = [[DemoGLFramebuffer alloc] initWithSize:CGSizeMake(self.imageBufferWidth, self.imageBufferHeight)];
    }
    [self.outputFramebuffer activateFramebuffer];
    
    glClearColor(0, 0, 0, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    // 注意这里的纹理坐标是特殊的,上下颠倒了一下，应该因为图像方向和纹理坐标系是反着的
    static const GLfloat textureCoordinates[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, self.yTexture);
    glUniform1i(self.yuvConversionYTextureUniform, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, self.uTexture);
    glUniform1i(self.yuvConversionUTextureUniform, 5);
    
    glActiveTexture(GL_TEXTURE6);
    glBindTexture(GL_TEXTURE_2D, self.vTexture);
    glUniform1i(self.yuvConversionVTextureUniform, 6);
    
    glUniformMatrix3fv(self.yuvConversionMatrixUniform, 1, GL_FALSE, self.preferredConversion);
    
    glVertexAttribPointer(self.yuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(self.yuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (CVPixelBufferRef)i420PixelBufferFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
    int bufferWidth = (int)CVPixelBufferGetWidth(cameraFrame);
    int bufferHeight = (int)CVPixelBufferGetHeight(cameraFrame);
    
    CVPixelBufferLockBaseAddress(cameraFrame, 0);
    
    const uint8_t *src_y = CVPixelBufferGetBaseAddressOfPlane(cameraFrame, 0);
    const uint8_t *src_uv = CVPixelBufferGetBaseAddressOfPlane(cameraFrame, 1);
    
    int src_stride_y = (int)CVPixelBufferGetBytesPerRowOfPlane(cameraFrame, 0);
    int src_stride_uv = (int)CVPixelBufferGetBytesPerRowOfPlane(cameraFrame, 1);
    
    
    CVPixelBufferRef i420Buffer = NULL;
    NSDictionary *attrDict = @{
        (NSString *)kCVPixelBufferIOSurfacePropertiesKey : @{},
        (NSString *)kCVPixelBufferOpenGLESCompatibilityKey : @(YES)
    };
    CVPixelBufferCreate(kCFAllocatorDefault, bufferWidth, bufferHeight, kCVPixelFormatType_420YpCbCr8Planar, (__bridge  CFDictionaryRef)attrDict, &i420Buffer);
    if (!i420Buffer) {
        CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
        NSLog(@"CVPixelBufferCreate error %s", __FUNCTION__);
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(i420Buffer, 0);

    int dst_stride_y = (int)CVPixelBufferGetBytesPerRowOfPlane(i420Buffer, 0);
    int dst_stride_u = (int)CVPixelBufferGetBytesPerRowOfPlane(i420Buffer, 1);
    int dst_stride_v = (int)CVPixelBufferGetBytesPerRowOfPlane(i420Buffer, 2);
    
    uint8_t *dst_y = CVPixelBufferGetBaseAddressOfPlane(i420Buffer, 0);
    uint8_t *dst_u = CVPixelBufferGetBaseAddressOfPlane(i420Buffer, 1);
    uint8_t *dst_v = CVPixelBufferGetBaseAddressOfPlane(i420Buffer, 2);
    
    int ret = NV12ToI420(src_y, src_stride_y,
                         src_uv, src_stride_uv,
                         dst_y, dst_stride_y,
                         dst_u, dst_stride_u,
                         dst_v, dst_stride_v,
                         bufferWidth, bufferHeight);
    
    CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
    
    if (ret) {
        CVPixelBufferUnlockBaseAddress(i420Buffer, 0);
        CVPixelBufferRelease(i420Buffer);
        NSLog(@"NV12ToI420 error: %d", ret);
        return NULL;
    }
    
    CVPixelBufferUnlockBaseAddress(i420Buffer, 0);
    return i420Buffer;
}


#pragma mark - DemoGLCapturePiplineDelegate

- (void)capturePipline:(DemoGLCapturePipline *)capturePipline didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if ((dispatch_semaphore_wait(self.frameRenderingSemaphore, DISPATCH_TIME_NOW)) != 0) {
        return;
    }
    CFRetain(sampleBuffer);
    runAsyncOnVideoProcessingQueue(^{
        
        [self processVideoSampleBuffer:sampleBuffer];
        
        CFRelease(sampleBuffer);
        dispatch_semaphore_signal(self.frameRenderingSemaphore);
    });
}

@end
