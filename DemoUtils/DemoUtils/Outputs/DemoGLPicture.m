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
#import "DemoGLFramebuffer.h"
#import "DemoGLDefines.h"

@interface DemoGLPicture ()

@property (nonatomic, assign) CGSize textureSize;
@property (nonatomic, strong) NSArray<UIImage *> *imageArray;
@property (nonatomic, assign) NSInteger currentImageIndex;


@end

@implementation DemoGLPicture

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        [self setupWithImage:image];
    }
    return self;
}


- (void)setupWithImage:(UIImage *)image {
    [self setupWithCGImage:image.CGImage originBottomLeft:NO];
}

- (void)setupWithCGImage:(CGImageRef)cgImage originBottomLeft:(BOOL)originBottomLeft {
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
    self.textureSize = pixelSizeForTexture;
    
    if (originBottomLeft) {
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
            CGImageGetBitsPerComponent(cgImage) != 8) {
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
        //kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst 是GL_BGRA
        // kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast 是GL_RGBA
        CGContextRef imageContext = CGBitmapContextCreate(imageData,
                                                          pixelSizeForTexture.width,
                                                          pixelSizeForTexture.height,
                                                          8,
                                                          pixelSizeForTexture.width * 4,
                                                          rgbColorSpace,
                                                          kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        
#if DEBUG
//            CGAffineTransform affineTransform = CGContextGetCTM(imageContext);
//            CATransform3D transform = CATransform3DMakeAffineTransform(affineTransform);
//            logTransform3D(transform);//此时transform是CATransform3DIdentity
#endif

        
        if (originBottomLeft) {
            CGContextTranslateCTM(imageContext, 0, pixelSizeForTexture.height);
            
            CGContextScaleCTM(imageContext, 1, -1);
#if DEBUG
//                CGAffineTransform affineTransform1 = CGContextGetCTM(imageContext);
//                CATransform3D transform1 = CATransform3DMakeAffineTransform(affineTransform1);
//                logTransform3D(transform1);
            /**
             此时transform1是
             1.0, 0.0, 0.0, 0.0,
             -0.0, -1.0, 0.0, 0.0,
             0.0, 0.0, 1.0, 0.0,
             0.0, 64.0, 0.0, 1.0,
             可见CGContextXXXCTM方法，是对CTM做了一次左乘运算
             从几何角度可以这里理解：左乘结果是 向量旋转 之后相对于原坐标系的位置， 右乘是参考系旋转移动后，向量(并未移动)相对于新参考系的坐标。
             CGContextConcatCTM 方法，直接用坐标系变化
             */
#endif
        }
        
        CGContextDrawImage(imageContext, CGRectMake(0, 0, pixelSizeForTexture.width, pixelSizeForTexture.height), cgImage);
        
#if DEBUG
            CGImageRef imageRef = CGBitmapContextCreateImage(imageContext);
            UIImage *image = [UIImage imageWithCGImage:imageRef];
            NSLog(@"%@", image.description);
            CFRelease(imageRef);
#endif
        
        CGContextRelease(imageContext);
        CGColorSpaceRelease(rgbColorSpace);
                    
    } else {
        CGDataProviderRef dataProvider = CGImageGetDataProvider(cgImage);
        dataFromImageDataProvider = CGDataProviderCopyData(dataProvider);
        imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
    }
    
    runSyncOnVideoProcessingQueue(^{
        [DemoGLContext useImageProcessingContext];
        if (!self.outputFramebuffer) {
            //注意，这里onlyGenerateTexture必须传YES，且不用activateFramebuffer，否则会报GL_INVALID_OPERATION
            self.outputFramebuffer = [[DemoGLFramebuffer alloc] initWithSize:pixelSizeForTexture onlyGenerateTexture:YES];
        }
        glBindTexture(GL_TEXTURE_2D, [self.outputFramebuffer texture]);
        // no need to use self.outputTextureOptions here since pictures need this texture formats and type
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)pixelSizeForTexture.width, (int)pixelSizeForTexture.height, 0, format, GL_UNSIGNED_BYTE, imageData);
        GetGLErrorOC();
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
    //这里如果是Async就会有问题，不知道为啥
    runSyncOnVideoProcessingQueue(^{
        for (int i = 0; i < self.targets.count; i++) {
            id<DemoGLInputProtocol> target = self.targets[i];
            NSInteger textureIndex = [self.targetTextureIndices[i] integerValue];
            [target setInputFramebuffer:self.outputFramebuffer atIndex:textureIndex];
            [target setInputTextureSize:self.textureSize atIndex:textureIndex];
            [target newFrameReadyAtTime:kCMTimeIndefinite timimgInfo:kCMTimingInfoInvalid];
        }
    });
}

@end



#pragma mark ----------------------------------DemoGLPicture (ImageArray)----------------------------------



@implementation DemoGLPicture (ImageArray)

- (instancetype)initWithImageArray:(NSArray<UIImage *> *)imageArray {
    self = [super init];
    if (self) {
        NSAssert(imageArray.count > 0, @"imageArray count should not be 0 !");
        _imageArray = imageArray;
    }
    return self;
}

- (void)setupWithNextImage {
    NSAssert(self.currentImageIndex >= 0 && self.currentImageIndex < self.imageArray.count, @"image index error !");
    UIImage *image = self.imageArray[self.currentImageIndex];
    [self setupWithImage:image];
    self.currentImageIndex += 1;
    if (self.currentImageIndex >= self.imageArray.count) {
        self.currentImageIndex = 0;
    }
}

- (BOOL)isUsingImageArray {
    return self.imageArray.count > 0;
}

@end
