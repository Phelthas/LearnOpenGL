//
//  DemoGLI420Camera3.m
//  Demo_OpenGLES_5
//
//  Created by billthaslu on 2022/3/5.
//

#import "DemoGLI420Camera3.h"
#import "DemoGLShaders.h"
#import "DemoGLProgram.h"
#import "DemoGLCapturePipline.h"
#import "DemoGLContext.h"
#import "DemoGLTextureFrame.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "libyuv.h"
#import "TimeCounter.h"

@interface DemoGLI420Camera3 ()<DemoGLCapturePiplineDelegate>

@property (nonatomic, strong) dispatch_semaphore_t frameRenderingSemaphore;
@property (nonatomic, strong) DemoGLProgram *yuvConversionProgram;
@property (nonatomic, assign) GLint yuvConversionPositionAttribute;
@property (nonatomic, assign) GLint yuvConversionTextureCoordinateAttribute;
@property (nonatomic, assign) GLint yuvConversionLuminanceTextureUniform;
@property (nonatomic, assign) GLint yuvConversionChrominanceTextureUniform;
@property (nonatomic, assign) GLint yuvConversionMatrixUniform;
@property (nonatomic, assign) const GLfloat *preferredConversion;
@property (nonatomic, assign) int imageBufferWidth;
@property (nonatomic, assign) int imageBufferHeight;
@property (nonatomic, assign) GLuint luminanceTexture;
@property (nonatomic, assign) GLuint chrominanceTexture;

@property (nonatomic, strong) TimeCounter *counter;

@end


@implementation DemoGLI420Camera3

- (void)dealloc {
    [self.counter logAllStatistics];
}

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition {
    self = [super initWithCameraPosition:cameraPosition];
    if (self) {
        _frameRenderingSemaphore = dispatch_semaphore_create(1);
        _preferredConversion = kColorConversion709;
        
        runSyncOnVideoProcessingQueue(^{
            [DemoGLContext useImageProcessingContext];
            if (self.capturePipline.isFullYUVRange) {
                self.yuvConversionProgram = [[DemoGLProgram alloc] initWithVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImageYUVFullRangeConversionForLAFragmentShaderString];
            } else {
                self.yuvConversionProgram = [[DemoGLProgram alloc] initWithVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImageYUVVideoRangeConversionForLAFragmentShaderString];
            }
            [self.yuvConversionProgram addAttribute:@"position"];
            [self.yuvConversionProgram addAttribute:@"inputTextureCoordinate"];
            if (![self.yuvConversionProgram link]) {
                self.yuvConversionProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
            self.yuvConversionPositionAttribute = [self.yuvConversionProgram attributeIndex:@"position"];
            self.yuvConversionTextureCoordinateAttribute = [self.yuvConversionProgram attributeIndex:@"inputTextureCoordinate"];
            self.yuvConversionLuminanceTextureUniform = [self.yuvConversionProgram uniformIndex:@"luminanceTexture"];
            self.yuvConversionChrominanceTextureUniform = [self.yuvConversionProgram uniformIndex:@"chrominanceTexture"];
            self.yuvConversionMatrixUniform = [self.yuvConversionProgram uniformIndex:@"colorConversionMatrix"];
                        
            glEnableVertexAttribArray(self.yuvConversionPositionAttribute);
            glEnableVertexAttribArray(self.yuvConversionTextureCoordinateAttribute);
            
        });
        
        _counter = [[TimeCounter alloc] init];
    }
    return self;
}

- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    CMSampleTimingInfo timimgInfo = kCMTimingInfoInvalid;
    CMSampleBufferGetSampleTimingInfo(sampleBuffer, 0, &timimgInfo);
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    int bufferWidth = (int)CVPixelBufferGetWidth(imageBuffer);
    int bufferHeight = (int)CVPixelBufferGetHeight(imageBuffer);
    if (self.imageBufferWidth != bufferWidth || self.imageBufferHeight != bufferHeight) {
        self.imageBufferWidth = bufferWidth;
        self.imageBufferHeight = bufferHeight;
    }
    
    unsigned char *i420Buffer = [self convertSampleBufferToI420:sampleBuffer];
    
    [self.counter countOnceStartWithKey:@"key1"];

    CVImageBufferRef cameraFrame = [self convertI420BufferToNV12PixelBuffer:i420Buffer witdth:bufferWidth height:bufferHeight];
    
    [self.counter countOnceEndWithKey:@"key1"];
    
    free(i420Buffer);
    
    
    [DemoGLContext useImageProcessingContext];
    CVPixelBufferLockBaseAddress(cameraFrame, 0);
    
    CVOpenGLESTextureRef luminanceTextureRef = NULL;
    CVOpenGLESTextureRef chrominanceTextureRef = NULL;
    if (CVPixelBufferGetPlaneCount(cameraFrame) > 0) {
        CVOpenGLESTextureCacheRef textureCache = [DemoGLContext sharedImageProcessingContext].coreVideoTextureCache;
        CVReturn ret;
        //Y-plane
        glActiveTexture(GL_TEXTURE4);
        ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, cameraFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth, bufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
        if (ret) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", ret);
        }
        self.luminanceTexture = CVOpenGLESTextureGetName(luminanceTextureRef);
        glBindTexture(GL_TEXTURE_2D, self.luminanceTexture);
        [self setupDefaultGLTexParameter];
        
        //UV-plane
        glActiveTexture(GL_TEXTURE5);
        ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, cameraFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, bufferWidth / 2, bufferHeight / 2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
        if (ret) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", ret);
        }
        self.chrominanceTexture = CVOpenGLESTextureGetName(chrominanceTextureRef);
        glBindTexture(GL_TEXTURE_2D, self.chrominanceTexture);
        [self setupDefaultGLTexParameter];
        
        [self convertYUVtoRGBoutput];
                
        CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
        
        CFRelease(cameraFrame);
        CFRelease(luminanceTextureRef);
        CFRelease(chrominanceTextureRef);
        
        for (id<DemoGLInputProtocol> target in self.targets) {
            [target setInputTexture:self.outputTextureFrame];
            [target setInputTextureSize:CGSizeMake(self.imageBufferWidth, self.imageBufferHeight)];
            [target newFrameReadyAtTime:currentTime timimgInfo:timimgInfo];
        }
        
    } else {
        NSLog(@"CVPixelBufferGetPlaneCount error");
    }
    
    
}

- (void)setupDefaultGLTexParameter {
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
}

- (void)convertYUVtoRGBoutput {
    [DemoGLContext useImageProcessingContext];
    [self.yuvConversionProgram use];
    
    if (!self.outputTextureFrame) {
        self.outputTextureFrame = [[DemoGLTextureFrame alloc] initWithSize:CGSizeMake(self.imageBufferWidth, self.imageBufferHeight)];
    }
    [self.outputTextureFrame activateFramebuffer];
    
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
    glBindTexture(GL_TEXTURE_2D, self.luminanceTexture);
    glUniform1i(self.yuvConversionLuminanceTextureUniform, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, self.chrominanceTexture);
    glUniform1i(self.yuvConversionChrominanceTextureUniform, 5);
    
    glUniformMatrix3fv(self.yuvConversionMatrixUniform, 1, GL_FALSE, self.preferredConversion);
    
    glVertexAttribPointer(self.yuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(self.yuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}


- (unsigned char *)convertSampleBufferToI420:(CMSampleBufferRef)sampleBuffer {

    CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    if (CMTIME_IS_INVALID(currentTime)) {
        NSLog(@"Invalid frame buffer CMTime.");
        return NULL;
    }

    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    int bufferWidth = (int)CVPixelBufferGetWidth(imageBuffer);
    int bufferHeight = (int)CVPixelBufferGetHeight(imageBuffer);
    
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // Get NV12 imageBuffer
    unsigned char *BaseAddrYPlane = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    unsigned char *BaseAddrUVPlane = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    size_t numberPerRowOfYPlane = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    size_t numberPerRowOfUVPlane = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
    
    /**
     // 系统貌似希望图片的宽度是64的整数倍，720不是，768才是，所以这里取到的width是720，但BytesPerRow是768
     size_t width = CVPixelBufferGetWidth(imageBuffer);
     size_t heightOfYPlane = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
     size_t heightOfUVPlane = CVPixelBufferGetHeightOfPlane(imageBuffer, 1);
     size_t extraColumnsOnLeft = 0;
     size_t extraColumnsOnRight = 0;
     size_t extraRowsOnTop = 0;
     size_t extraRowsOnBottom = 0;
     
     CVPixelBufferGetExtendedPixels(imageBuffer, &extraColumnsOnLeft, &extraColumnsOnRight, &extraRowsOnTop, &extraRowsOnBottom);

     // Do color space conversion in Video Engine
     size_t nBufferSize = width * (heightOfYPlane + heightOfUVPlane);
     unsigned char *pCamBuffer = malloc(nBufferSize);
     if (!pCamBuffer) {
         NSLog(@"new buffer exception:captureOutput ;size:%lu", nBufferSize);

         CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

         return NULL;
     }

     unsigned char *pTempBuffer = pCamBuffer;
     if (numberPerRowOfUVPlane == width) {
         memcpy(pCamBuffer, BaseAddrYPlane, width * heightOfYPlane);
         memcpy(pCamBuffer + width * heightOfYPlane, BaseAddrUVPlane, width * heightOfUVPlane);
     } else {
         for (int i = 0; i < heightOfYPlane; i++) {
             memcpy(pTempBuffer, BaseAddrYPlane + extraRowsOnTop * numberPerRowOfYPlane + extraColumnsOnLeft, width);
             BaseAddrYPlane += numberPerRowOfYPlane;
             pTempBuffer += width;
         }
         for (int i = 0; i < heightOfUVPlane; i++) {
             memcpy(pTempBuffer, BaseAddrUVPlane + extraRowsOnTop * numberPerRowOfUVPlane + extraColumnsOnLeft, width);
             BaseAddrUVPlane += numberPerRowOfUVPlane;
             pTempBuffer += width;
         }
     }
     */

    
    size_t bufferSize = bufferWidth * bufferHeight * 3 / 2;
    uint8_t *dst_y = (uint8_t *)malloc(bufferSize);
    uint8_t *dst_u = dst_y + bufferWidth * bufferHeight;
    uint8_t *dst_v = dst_y + bufferWidth * bufferHeight * 5 / 4;
    
    int dst_stride_y = (int)bufferWidth;
    int dst_stride_u = (int)bufferWidth / 2;
    int dst_stride_v = (int)bufferWidth / 2;
    
    int ret = NV12ToI420(BaseAddrYPlane, (int)numberPerRowOfYPlane,
                         BaseAddrUVPlane, (int)numberPerRowOfUVPlane,
                         dst_y, dst_stride_y,
                         dst_u, dst_stride_u,
                         dst_v, dst_stride_v,
                         bufferWidth, bufferHeight);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

    if (ret) {
        NSLog(@"NV12ToI420 error: %d", ret);
        free(dst_y);
        return NULL;
    }
    
    return dst_y;

}


- (CVImageBufferRef)convertI420BufferToNV12PixelBuffer:(unsigned char *)i420Buffer witdth:(int)bufferWidth height:(int)bufferHeight {
    
    unsigned char *src_y = i420Buffer;
    unsigned char *src_u = i420Buffer + bufferWidth * bufferHeight;
    unsigned char *src_v = i420Buffer + bufferWidth * bufferHeight * 5 / 4;
    
    CVPixelBufferRef nv12Buffer = NULL;
    NSDictionary *attrDict = @{
        (NSString *)kCVPixelBufferIOSurfacePropertiesKey : @{},
        (NSString *)kCVPixelBufferOpenGLESCompatibilityKey : @(YES)
    };
    CVPixelBufferCreate(kCFAllocatorDefault, bufferWidth, bufferHeight, kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, (__bridge  CFDictionaryRef)attrDict, &nv12Buffer);
    if (!nv12Buffer) {
        NSLog(@"CVPixelBufferCreate error %s", __FUNCTION__);
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(nv12Buffer, 0);

    uint8_t *dst_y = CVPixelBufferGetBaseAddressOfPlane(nv12Buffer, 0);
    uint8_t *dst_uv = CVPixelBufferGetBaseAddressOfPlane(nv12Buffer, 1);
    
    int dst_stride_y = (int)CVPixelBufferGetBytesPerRowOfPlane(nv12Buffer, 0);
    int dst_stride_uv = (int)CVPixelBufferGetBytesPerRowOfPlane(nv12Buffer, 1);
    
    int ret = I420ToNV12(src_y, bufferWidth,
                         src_u, bufferWidth / 2,
                         src_v, bufferWidth / 2,
                         dst_y, dst_stride_y,
                         dst_uv, dst_stride_uv,
                         bufferWidth, bufferHeight);
        
    CVPixelBufferUnlockBaseAddress(nv12Buffer, 0);
    
    if (ret) {
        CVPixelBufferRelease(nv12Buffer);
        NSLog(@"I420ToNV12 error: %d", ret);
        return NULL;
    }
    
    return nv12Buffer;
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
