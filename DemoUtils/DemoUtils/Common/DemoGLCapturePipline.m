//
//  DemoGLCapturePipline.m
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import "DemoGLCapturePipline.h"

@interface DemoGLCapturePipline ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) dispatch_queue_t dataOutputQueue;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;

@property (nonatomic, assign, readwrite) BOOL isFullYUVRange;


@end

@implementation DemoGLCapturePipline

- (instancetype)init {
    return [self initWithCameraPosition:AVCaptureDevicePositionBack];
}

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition {
    self = [super init];
    if (self) {
        _cameraPosition = cameraPosition;
        _sessionQueue = dispatch_queue_create("DemoCapturePipline.sessionQueue", DISPATCH_QUEUE_SERIAL);
        _dataOutputQueue = dispatch_queue_create("DemoCapturePipline.dataOutputQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_dataOutputQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
        [self setupCaptureSession];
    }
    return self;
}

- (void)setupCaptureSession {
    if (_captureSession) {
        return;
    }
    _captureSession = [[AVCaptureSession alloc] init];
    
    NSArray<AVCaptureDevice *> *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *frontDevice = nil;
    for (AVCaptureDevice *device in deviceArray) {
        if (device.position == self.cameraPosition) {
            frontDevice = device;
            break;
        }
    }
    NSError *error;
    [frontDevice lockForConfiguration:&error];
    if (!error) {
        [frontDevice setActiveVideoMinFrameDuration:CMTimeMake(1, 30)];
        [frontDevice setActiveVideoMaxFrameDuration:CMTimeMake(1, 30)];
    } else {
        
    }
    [frontDevice unlockForConfiguration];
    
    NSError *deviceInputError = nil;
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:frontDevice error:&deviceInputError];
    if ([_captureSession canAddInput:_videoInput]) {
        [_captureSession addInput:_videoInput];
    } else {
        NSLog(@"error is %@", deviceInputError);
    }
    
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;

    BOOL supportFullRange = NO;
    NSArray *supportedPixelFormats = _videoDataOutput.availableVideoCVPixelFormatTypes;
    for (NSNumber *pixelFormat in supportedPixelFormats) {
        if ([pixelFormat integerValue] == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
            supportFullRange = YES;
        }
    }
    if (supportFullRange) {
        _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        self.isFullYUVRange = YES;
    } else {
        _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
        self.isFullYUVRange = NO;
    }
    
    /**
        See AVVideoSettings.h for more information on how to construct a video settings dictionary. To receive samples in their device native format, set this property to an empty dictionary (i.e. [NSDictionary dictionary]). To receive samples in a default uncompressed format, set this property to nil. Note that after this property is set to nil, subsequent querying of this property will yield a non-nil dictionary reflecting the settings used by the AVCaptureSession's current sessionPreset.
     
        On iOS, the only supported key is kCVPixelBufferPixelFormatTypeKey. Supported pixel formats are kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, kCVPixelFormatType_420YpCbCr8BiPlanarFullRange and kCVPixelFormatType_32BGRA.
     */
    
    /**
     dataOutput.videoSettings = [NSDictionary dictionary];
     dataOutput.videoSettings = nil;
     在iPhone X上，分别设置以上两句，回调中拿到的videoSettings都是
     {
     Height = 1080;
     PixelFormatType = 875704438; //即kCVPixelFormatType_422YpCbCr8BiPlanarVideoRange = '420v'
     Width = 1920;
     }
     kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange,kCVPixelFormatType_420YpCbCr8BiPlanarFullRange不完全一样，
     YUV格式有两大类，packed和planar，前者将 YUV 分量存放在同一个数组中,
     通常是几个相邻的像素组成一个宏像素(macro-pixel);而后者使用三个数组分开存放 YUV 三个分量,
     就像是一个三维平面一样。
     而VideoRange和FullRange的不同，在定义里有注释。
     */
    
//    dataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
//    dataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
//    dataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        
    [_videoDataOutput setSampleBufferDelegate:self queue:_dataOutputQueue];
    if ([_captureSession canAddOutput:_videoDataOutput]) {
        [_captureSession addOutput:_videoDataOutput];
    }
    
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [_captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    
}

- (void)setupAVCaptureConnectionWithBlock:(DemoGLCaptureConnectionConfigure)configureBlock {
    if (!self.videoConnection) {
        self.videoConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    }
    if (configureBlock) {
        configureBlock(self.videoConnection);
    }
    
}

- (void)dealloc {
    [self stopRunning];
    [self.videoDataOutput setSampleBufferDelegate:nil queue:nil];
}

#pragma mark - PublicMethod

- (void)startRunning {
    dispatch_sync(_sessionQueue, ^{
        [self setupCaptureSession];
        if (![_captureSession isRunning]) {
            [_captureSession startRunning];
        }
    });
}

- (void)stopRunning {
    dispatch_sync(_sessionQueue, ^{
        if ([_captureSession isRunning]) {
            [_captureSession stopRunning];
        }
    });
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    /**
     AVCaptureVideoDataOutput *dataOutput = (AVCaptureVideoDataOutput *)output;
     NSDictionary *dict = dataOutput.videoSettings;
     NSInteger pixelFormatType = [dict[(id)kCVPixelBufferPixelFormatTypeKey] integerValue];
     if (pixelFormatType == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
         NSLog(@"kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange");
     } else if (pixelFormatType == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange) {
         NSLog(@"kCVPixelFormatType_420YpCbCr8BiPlanarFullRange");
     }
     貌似在这里判断videoSettings的值也可以判断出sampleBuffer的格式，但是GPUImage是在设置的时候记录一下，然后用sampleBuffer
     中的字段来判断的，不知道有啥深意
     */
    
    
//    NSLog(@"dataOutput.videoSettings is \n %@", dict);
    
    /**
     iPhoneX上的默认值
     Height = 1080;
     PixelFormatType = 875704438; //即kCVPixelFormatType_422YpCbCr8BiPlanarVideoRange = '420v'
     Width = 1920;
     '420v'是c++的语法 单引号字符串，其值是 '4' << 24  + '2' << 16 + '0' << 8 + 'v'
     其中 int('0')=48, int('a')=97, int('A')=65
     */
    
    /**
     前面没有设置connection.videoOrientation时，
     如果是前置摄像头，这里取到的是AVCaptureVideoOrientationLandscapeLeft
     如果是后置摄像头，这里取到的是AVCaptureVideoOrientationLandscapeRight
     */
    
//    NSLog(@"sampleBuffer is %@", sampleBuffer);
    
//    CMSampleBufferRef tempBuffer = sampleBuffer;
//    CFDictionaryRef dict = CMGetAttachment(sampleBuffer, kCGImagePropertyExifDictionary, NULL);
//    CFDictionaryRef temp = CMGetAttachment(sampleBuffer, kCGImagePropertyOrientation, NULL);
    
#if DEBUG
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    UIImage *image = [self uiImageFromPixelBuffer:imageBuffer];
    
#endif
    

    
    if ([self.delegate respondsToSelector:@selector(capturePipline:didOutputSampleBuffer:)]) {
        [self.delegate capturePipline:self didOutputSampleBuffer:sampleBuffer];
    }

}

- (UIImage *)uiImageFromPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CIImage* ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CIContext* context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
    
    CGRect rect = CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer));
    CGImageRef videoImage = [context createCGImage:ciImage fromRect:rect];
    
    UIImage* image = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
    return image;
}


@end
