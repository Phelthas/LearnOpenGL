//
//  DemoGLVideoCamera4.m
//  Demo_OpenGLES_5
//
//  Created by lu xiaoming on 2022/3/11.
//

#import "DemoGLVideoCamera4.h"
#import "DemoGLShaders.h"
#import "DemoGLProgram.h"
#import "DemoGLCapturePipline.h"
#import "DemoGLContext.h"
#import "DemoGLTextureFrame.h"
#import "DemoGLUtility.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <UIKit/UIKit.h>

@interface DemoGLVideoCamera4 ()<DemoGLCapturePiplineDelegate>


@property (nonatomic, strong) DemoGLTextureFrame *outputFramebuffer;
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


@end


@implementation DemoGLVideoCamera4

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
    }
    return self;
}

- (DemoGLTextureFrame *)framebufferForOutput {
    return _outputFramebuffer;
}

- (void)processVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer {

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
    } else {
        if (self.capturePipline.isFullYUVRange) {
            self.preferredConversion = kColorConversion601FullRange;
        } else {
            self.preferredConversion = kColorConversion601;
        }
    }
    
    CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    CMSampleTimingInfo timimgInfo = kCMTimingInfoInvalid;
    CMSampleBufferGetSampleTimingInfo(sampleBuffer, 0, &timimgInfo);
    [DemoGLContext useImageProcessingContext];
    if ([DemoGLContext supportsFastTextureUpload]) {
        CVOpenGLESTextureRef luminanceTextureRef = NULL;
        CVOpenGLESTextureRef chrominanceTextureRef = NULL;
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
            ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, cameraFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth, bufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
            if (ret) {
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", ret);
            }
            self.luminanceTexture = CVOpenGLESTextureGetName(luminanceTextureRef);
            glBindTexture(GL_TEXTURE_2D, self.luminanceTexture);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            //UV-plane
            glActiveTexture(GL_TEXTURE5);
            ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, cameraFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, bufferWidth / 2, bufferHeight / 2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
            if (ret) {
                NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", ret);
            }
            self.chrominanceTexture = CVOpenGLESTextureGetName(chrominanceTextureRef);
            glBindTexture(GL_TEXTURE_2D, self.chrominanceTexture);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            [self convertYUVtoRGBoutput];
            
            CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
            CFRelease(luminanceTextureRef);
            CFRelease(chrominanceTextureRef);
            
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
    else {
        CVPixelBufferLockBaseAddress(cameraFrame, 0);
        int bytesPerRow = (int)CVPixelBufferGetBytesPerRow(cameraFrame);
        if (!_outputFramebuffer) {
            _outputFramebuffer = [[DemoGLTextureFrame alloc] initWithSize:CGSizeMake(bytesPerRow / 4, bufferHeight)];
        }
        [_outputFramebuffer activateFramebuffer];
        
        glBindTexture(GL_TEXTURE_2D, [_outputFramebuffer texture]);
        // Using BGRA extension to pull in video frame data directly
        // The use of bytesPerRow / 4 accounts for a display glitch present in preview video frames when using the photo preset on the camera
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, bytesPerRow / 4, bufferHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, CVPixelBufferGetBaseAddress(cameraFrame));
        
        CVPixelBufferUnlockBaseAddress(cameraFrame, 0);
        
        for (id<DemoGLInputProtocol> target in self.targets) {
            [target setInputTexture:self.outputFramebuffer];
            [target newFrameReadyAtTime:currentTime timimgInfo:timimgInfo];
        }
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
    glBindTexture(GL_TEXTURE_2D, self.luminanceTexture);
    glUniform1i(self.yuvConversionLuminanceTextureUniform, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, self.chrominanceTexture);
    glUniform1i(self.yuvConversionChrominanceTextureUniform, 5);
    
    glUniformMatrix3fv(self.yuvConversionMatrixUniform, 1, GL_FALSE, self.preferredConversion);
    
    glVertexAttribPointer(self.yuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(self.yuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self drawYPlaneOnly];
    [self drawUVPlaneOnly];
     
}

- (void)drawYPlaneOnly {
    //注意，这里不能clear，clear就把之前绘制上去的内容清掉了
    static const GLfloat squareVertices2[] = {
        0.5f, -1.0f,
        1.0f, -1.0f,
        0.5f, -0.5f,
        1.0f, -0.5f,
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
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glVertexAttribPointer(self.yuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices2);
    glVertexAttribPointer(self.yuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

- (void)drawUVPlaneOnly {
    //注意，这里不能clear，clear就把之前绘制上去的内容清掉了
    static const GLfloat squareVertices3[] = {
        -1.0f, -1.0f,
        -0.5f, -1.0f,
        -1.0f, -0.5f,
        -0.5f, -0.5f,
    };
    
    // 注意这里的纹理坐标是特殊的,上下颠倒了一下，应该因为图像方向和纹理坐标系是反着的
    static const GLfloat textureCoordinates[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, self.chrominanceTexture);
    glUniform1i(self.yuvConversionChrominanceTextureUniform, 5);
    
    glVertexAttribPointer(self.yuvConversionPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices3);
    glVertexAttribPointer(self.yuvConversionTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
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

