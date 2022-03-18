//
//  DemoGLPicture.m
//  DemoUtils
//
//  Created by lu xiaoming on 2022/3/17.
//

#import "DemoGLPicture.h"
#import "DemoGLContext.h"
#import "LXMKit.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "DemoGLTextureFrame.h"

@interface DemoGLPicture ()

@property (nonatomic, strong) DemoGLTextureFrame *outputFramebuffer;

@end

@implementation DemoGLPicture

- (instancetype)initWithImage:(UIImage *)image {
    return [self initWithCGImage:image.CGImage];
}

- (instancetype)initWithCGImage:(CGImageRef)cgImage {
    self = [super init];
    if (self) {
        
        CGFloat imageWidth = CGImageGetWidth(cgImage);
        CGFloat imageHeight = CGImageGetHeight(cgImage);
        NSAssert(imageWidth > 0 && imageHeight > 0, @"image should not be empty");
        
        CGSize pixelSizeForTexture = CGSizeMake(imageWidth, imageHeight);
        CGSize appropriateSize = [self appropriateSizeWithinMaxSizeForTextureSize:pixelSizeForTexture];
        BOOL shouldRedrawWithCoreGraphics = NO;
        if (!CGSizeEqualToSize(pixelSizeForTexture, appropriateSize)) {
            pixelSizeForTexture = appropriateSize;
            shouldRedrawWithCoreGraphics = YES;
        }
        
        GLubyte *imageData = NULL;
        CFDataRef dataFromImageDataProvider = NULL;
        GLenum format = GL_BGRA;
        
        if (!shouldRedrawWithCoreGraphics) {
            /* Check that the memory layout is compatible with GL, as we cannot use glPixelStore to
             * tell GL about the memory layout with GLES.
             */
            if (CGImageGetBytesPerRow(cgImage) != imageWidth * 4 ||
                CGImageGetBitsPerPixel(cgImage) != 32 ||
                CGImageGetBitsPerComponent(cgImage) != 4) {
                shouldRedrawWithCoreGraphics = YES;
            } else {
                /* Check that the bitmap pixel format is compatible with GL */
                CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
                if ((bitmapInfo & kCGBitmapFloatComponents) != 0) {
                    /* We don't support float components for use directly in GL */
                    shouldRedrawWithCoreGraphics = YES;
                } else {
                    CGBitmapInfo byteOrderInfo = bitmapInfo & kCGBitmapByteOrderMask;
                    if (byteOrderInfo == kCGBitmapByteOrder32Little) {
                        /* Little endian, for alpha-first we can use this bitmap directly in GL */
                        CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
                        if (alphaInfo != kCGImageAlphaPremultipliedFirst &&
                            alphaInfo != kCGImageAlphaFirst &&
                            alphaInfo != kCGImageAlphaNoneSkipFirst) {
                            shouldRedrawWithCoreGraphics = YES;
                        }
                    } else if (byteOrderInfo == kCGBitmapByteOrderDefault || kCGBitmapByteOrder32Big) {
                        /* Big endian, for alpha-last we can use this bitmap directly in GL */
                        CGImageAlphaInfo alphaInfo = bitmapInfo & kCGBitmapAlphaInfoMask;
                        if (alphaInfo != kCGImageAlphaPremultipliedLast &&
                            alphaInfo != kCGImageAlphaLast &&
                            alphaInfo != kCGImageAlphaNoneSkipLast) {
                            shouldRedrawWithCoreGraphics = YES;
                        } else {
                            /* Can access directly using GL_RGBA pixel format */
                            format = GL_RGBA;
                        }
                    }
                }
            }
        }
        
        if (shouldRedrawWithCoreGraphics) {
            imageData = (GLubyte *)calloc(1, (int)pixelSizeForTexture.width * (int)pixelSizeForTexture.height * 4);
            CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef imageContext = CGBitmapContextCreate(imageData, pixelSizeForTexture.width, pixelSizeForTexture.height, 8, pixelSizeForTexture.width * 4, rgbColorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
            CGContextDrawImage(imageContext, CGRectMake(0, 0, pixelSizeForTexture.width, pixelSizeForTexture.height), cgImage);
            CGContextRelease(imageContext);
            CGColorSpaceRelease(rgbColorSpace);
        } else {
            CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
            dataFromImageDataProvider = CGDataProviderCopyData(dataProvider);
            imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
        }
        
        runSyncOnVideoProcessingQueue(^{
            [DemoGLContext useImageProcessingContext];
            if (!_outputFramebuffer) {
                _outputFramebuffer = [[DemoGLTextureFrame alloc] initWithSize:pixelSizeForTexture];
            }
//            [_outputFramebuffer activateFramebuffer];
            glBindTexture(GL_TEXTURE_2D, [self.outputFramebuffer texture]);
            // no need to use self.outputTextureOptions here since pictures need this texture formats and type
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, pixelSizeForTexture.width, pixelSizeForTexture.height, 0, format, GL_UNSIGNED_BYTE, imageData);
            glBindTexture(GL_TEXTURE_2D, 0);
            
        });
        
        if (shouldRedrawWithCoreGraphics) {
            free(imageData);
        } else {
            if (dataFromImageDataProvider) {
                CFRelease(dataFromImageDataProvider);
            }
        }
        
    }
    return self;
}

- (CGSize)appropriateSizeWithinMaxSizeForTextureSize:(CGSize)textureSize {
    CGFloat maxWidth = [DemoGLContext maximumTextureSizeForThisDevice];
    // 如果纹理大小<设备支持的最大size，则可以直接使用，否则要缩放到支持的size以内
    if (textureSize.width <= maxWidth && textureSize.height <= maxWidth) {
        return textureSize;
    }
    CGSize result = [LXMAspectUtil aspectFitSizeForSourceSize:textureSize destinationSize:CGSizeMake(maxWidth, maxWidth)];
    return result;
    
}

- (void)processImage {
    runAsyncOnVideoProcessingQueue(^{
        for (id<DemoGLInputProtocol> target in self.targets) {
            [target setInputTexture:self.outputFramebuffer];
            [target newFrameReadyAtTime:kCMTimeIndefinite timimgInfo:kCMTimingInfoInvalid];
        }
    });
}

@end
