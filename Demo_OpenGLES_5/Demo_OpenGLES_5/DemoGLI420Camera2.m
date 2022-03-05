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

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition {
    self = [super initWithCameraPosition:cameraPosition];
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
            
            [self generateTextureWithTextureId:&self->_yTexture];
            [self generateTextureWithTextureId:&self->_uTexture];
            [self generateTextureWithTextureId:&self->_vTexture];
            
        });
    }
    return self;
}

- (void)generateTextureWithTextureId:(GLuint *)textureId {
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, textureId);
    glBindTexture(GL_TEXTURE_2D, *textureId);
}

- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    CMSampleTimingInfo timimgInfo = kCMTimingInfoInvalid;
    CMSampleBufferGetSampleTimingInfo(sampleBuffer, 0, &timimgInfo);
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    int bufferWidth = (int)CVPixelBufferGetWidth(imageBuffer);
    int bufferHeight = (int)CVPixelBufferGetHeight(imageBuffer);
    unsigned char *i420Buffer = [self convertSampleBufferToI420:sampleBuffer];
    unsigned char *dst_y = i420Buffer;
    unsigned char *dst_u = i420Buffer + bufferWidth * bufferHeight;
    unsigned char *dst_v = i420Buffer + bufferWidth * bufferHeight * 5 / 4;
    
    [DemoGLContext useImageProcessingContext];
    
    [self textureY:dst_y widthType:bufferWidth heightType:bufferHeight texture:&_yTexture];
    [self textureY:dst_u widthType:bufferWidth / 2 heightType:bufferHeight / 2 texture:&_uTexture];
    [self textureY:dst_v widthType:bufferWidth / 2 heightType:bufferHeight / 2 texture:&_vTexture];
    
    [self convertI420toRGBoutput];
    
    
    free(i420Buffer);
    for (id<DemoGLInputProtocol> target in self.targets) {
        [target setInputTexture:self.outputFramebuffer];
        [target newFrameReadyAtTime:currentTime timimgInfo:timimgInfo];
    }
    
    
}

- (void)convertI420toRGBoutput {
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
    // 系统貌似希望图片的宽度是64的整数倍，720不是，768才是，所以这里取到的width是720，但BytesPerRow是768
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

    /**
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
        return NULL;
    }
    
    return dst_y;

}


- (void)textureY:(unsigned char *)imageData widthType:(int)width heightType:(int)height texture:(GLuint *)texture {
    if (texture == 0 || imageData == nil) {
        return;
    }
    glBindTexture(GL_TEXTURE_2D, *texture);
    
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    // This is necessary for non-power-of-two textures
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexImage2D( GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, imageData );
    glBindTexture(GL_TEXTURE_2D, 0);
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
