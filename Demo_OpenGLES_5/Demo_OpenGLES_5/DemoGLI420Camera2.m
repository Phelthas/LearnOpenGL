//
//  DemoGLI420Camera2.m
//  Demo_OpenGLES_5
//
//  Created by billthaslu on 2022/3/4.
//

#import "DemoGLI420Camera2.h"
#import "DemoGLShaders.h"
#import "DemoGLProgram.h"
#import "DemoGLCapturePipline.h"
#import "DemoGLContext.h"
#import "DemoGLTextureFrame.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "libyuv.h"

@interface DemoGLI420Camera2 ()<DemoGLCapturePiplineDelegate>

@property (nonatomic, strong) DemoGLTextureFrame *outputFramebuffer;
@property (nonatomic, strong) DemoGLCapturePipline *capturePipline;
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


@implementation DemoGLI420Camera2

- (instancetype)init {
    return [self initWithCameraPosition:AVCaptureDevicePositionFront];
}

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition {
    self = [super init];
    if (self) {
        _frameRenderingSemaphore = dispatch_semaphore_create(1);
        _capturePipline = [[DemoGLCapturePipline alloc] initWithCameraPosition:cameraPosition];
        _capturePipline.delegate = self;
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

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    
    [self.capturePipline stopRunning];
    
#if !OS_OBJECT_USE_OBJC
    if (self.frameRenderingSemaphore != NULL) {
        dispatch_release(self.frameRenderingSemaphore);
    }
#endif
    
}

- (DemoGLTextureFrame *)framebufferForOutput {
    return _outputFramebuffer;
}

- (void)generateTextureWithTextureId:(GLuint *)textureId {
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, textureId);
    glBindTexture(GL_TEXTURE_2D, *textureId);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    // This is necessary for non-power-of-two textures
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
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
            //测试表明：创建一个3Plane的CVImageBufferRef在这里创建纹理，会报错kCVReturnPixelBufferNotOpenGLCompatible；
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
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", ret);
        }
        self.vTexture = CVOpenGLESTextureGetName(vTextureRef);
        glBindTexture(GL_TEXTURE_2D, self.vTexture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        [self convertYUVtoRGBoutput];
        
        CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
        CFRelease(yTextureRef);
        CFRelease(uTextureRef);
        CFRelease(vTextureRef);
        
        for (id<DemoGLInputProtocol> target in self.targets) {
            [target setInputTexture:self.outputFramebuffer];
            [target newFrameReadyAtTime:currentTime timimgInfo:timimgInfo];
        }
        
    }
    else {
        // TODO: Mesh this with the output framebuffer structure
        // GPUImage 也没做处理
    }
    
}

- (void)convertYUVtoRGBoutput {
    [DemoGLContext useImageProcessingContext];
    [self.yuvConversionProgram use];
    
    if (!_outputFramebuffer) {
        _outputFramebuffer = [[DemoGLTextureFrame alloc] initWithSize:CGSizeMake(self.imageBufferWidth, self.imageBufferHeight)];
    }
    [_outputFramebuffer activateFramebuffer];
    
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
    if (self.imageBufferWidth != bufferWidth || self.imageBufferHeight != bufferHeight) {
        self.imageBufferWidth = bufferWidth;
        self.imageBufferHeight = bufferHeight;
    }
    CMSampleTimingInfo timimgInfo = kCMTimingInfoInvalid;
    CMSampleBufferGetSampleTimingInfo(sampleBuffer, 0, &timimgInfo);
    
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);

    // Get NV12 imageBuffer
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t heightOfYPlane = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    size_t heightOfUVPlane = CVPixelBufferGetHeightOfPlane(imageBuffer, 1);
    unsigned char *BaseAddrYPlane = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    unsigned char *BaseAddrUVPlane = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    size_t numberPerRowOfYPlane = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    size_t numberPerRowOfUVPlane = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
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

    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    
    unsigned char *dstBuffer = malloc(nBufferSize);
    
    [self nv12toi420ColorConvert:pTempBuffer toBuf:dstBuffer width:(int)width height:(int)heightOfYPlane];

    free(pCamBuffer);
    
    [self textureY:dstBuffer + width widthType:width heightType:heightOfYPlane texture:&_yTexture];
    [self textureY:dstBuffer + width * heightOfYPlane widthType:width / 2 heightType:heightOfYPlane / 2 texture:&_uTexture];
    [self textureY:dstBuffer + width * heightOfYPlane * 5 / 4 widthType:width / 2 heightType:heightOfYPlane / 2 texture:&_vTexture];
    
    [self convertYUVtoRGBoutput];
    
    for (id<DemoGLInputProtocol> target in self.targets) {
        [target setInputTexture:self.outputFramebuffer];
        [target newFrameReadyAtTime:currentTime timimgInfo:timimgInfo];
    }
    
    return dstBuffer;

}

- (void)nv12toi420ColorConvert:(unsigned char *)src toBuf:(unsigned char *)dst width:(int)nWidth height:(int)nHeight {
    NV12ToI420(src, nWidth,
               src + nWidth * nHeight, nWidth,
               dst, nWidth,
               dst + nWidth * nHeight, nWidth>>1,
               dst + nWidth * nHeight * 5 / 4, nWidth>>1,
               nWidth, nHeight);
}


- (void)textureY:(unsigned char *)imageData widthType:(int)width heightType:(int)height texture:(GLuint *)texture {
    if (texture == 0 || imageData == nil) {
        return;
    }
    glBindTexture(GL_TEXTURE_2D, *texture);
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D( GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, imageData );
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (CVPixelBufferRef)i420PixelBufferFromSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef cameraFrame = CMSampleBufferGetImageBuffer(sampleBuffer);
    int bufferWidth = (int)CVPixelBufferGetWidth(cameraFrame);
    int bufferHeight = (int)CVPixelBufferGetHeight(cameraFrame);
    CFTypeRef colorAttachments = CVBufferGetAttachment(cameraFrame, kCVImageBufferYCbCrMatrixKey, NULL);
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
    
    CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    CMSampleTimingInfo timimgInfo = kCMTimingInfoInvalid;
    CMSampleBufferGetSampleTimingInfo(sampleBuffer, 0, &timimgInfo);
    
    CVPixelBufferLockBaseAddress(cameraFrame, 0);
    
    const uint8_t *src_y = CVPixelBufferGetBaseAddressOfPlane(cameraFrame, 0);
    
    const uint8_t *src_uv = CVPixelBufferGetBaseAddressOfPlane(cameraFrame, 1);
    
    int yPlaneBytesPerRow = (int)CVPixelBufferGetBytesPerRowOfPlane(cameraFrame, 0);
    int uvPlaneBytesPerRow = (int)CVPixelBufferGetBytesPerRowOfPlane(cameraFrame, 1);
    size_t frameSize = bufferWidth * bufferHeight * 3 / 2;
    
    /*
    uint8_t *buffer = (unsigned char *)malloc(frameSize);
    uint8_t *dst_u = buffer + bufferWidth * bufferHeight;
    uint8_t *dst_v = buffer + bufferWidth * bufferHeight * 5 / 4;
    
    int ret = NV12ToI420(yFrame, yPlaneBytesPerRow,
                         uvFrame, uvPlaneBytesPerRow,
                         buffer, bufferWidth,
                         dst_u, bufferWidth / 2,
                         dst_v, bufferWidth / 2,
                         bufferWidth, bufferHeight);
    
    if (ret) {
        NSLog(@"NV12ToI420 error: %d", ret);
        return NULL;
    }
    */
    
    CVPixelBufferRef i420Buffer = NULL;
    NSDictionary *attrDict = @{(NSString *)kCVPixelBufferIOSurfacePropertiesKey : @{}};
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
    
    int ret = NV12ToI420(src_y, yPlaneBytesPerRow,
                         src_uv, uvPlaneBytesPerRow,
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

#pragma mark - PublicMethod

- (void)setupAVCaptureConnectionWithBlock:(DemoGLCaptureConnectionConfigure)configureBlock {
    [self.capturePipline setupAVCaptureConnectionWithBlock:configureBlock];
}

- (void)startCameraCapture {
    [self.capturePipline startRunning];
}

- (void)stopCameraCapture {
    [self.capturePipline stopRunning];
}

#pragma mark - DemoGLCapturePiplineDelegate

- (void)capturePipline:(DemoGLCapturePipline *)capturePipline didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    if ((dispatch_semaphore_wait(self.frameRenderingSemaphore, DISPATCH_TIME_NOW)) != 0) {
        return;
    }
    CFRetain(sampleBuffer);
    runAsyncOnVideoProcessingQueue(^{
        
        [self processVideoSampleBuffer:sampleBuffer];
//        unsigned char *i420Buffer = [self convertSampleBufferToI420:sampleBuffer];
//
//        free(i420Buffer);
        
        CFRelease(sampleBuffer);
        dispatch_semaphore_signal(self.frameRenderingSemaphore);
    });
}

@end
