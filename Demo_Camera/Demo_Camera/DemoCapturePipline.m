//
//  DemoCapturePipline.m
//  Demo_Camera
//
//  Created by billthaslu on 2021/4/2.
//

#import "DemoCapturePipline.h"
#import <AVFoundation/AVFoundation.h>


@interface DemoCapturePipline ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) dispatch_queue_t dataOutputQueue;



@end

@implementation DemoCapturePipline

- (instancetype)init {
    self = [super init];
    if (self) {
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
        if (device.position == AVCaptureDevicePositionFront) {
            frontDevice = device;
            break;
        }
    }
    NSError *deviceInputError = nil;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:frontDevice error:&deviceInputError];
    if ([_captureSession canAddInput:input]) {
        [_captureSession addInput:input];
    } else {
        NSLog(@"error is %@", deviceInputError);
    }
    
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    /**
        See AVVideoSettings.h for more information on how to construct a video settings dictionary. To receive samples in their device native format, set this property to an empty dictionary (i.e. [NSDictionary dictionary]). To receive samples in a default uncompressed format, set this property to nil. Note that after this property is set to nil, subsequent querying of this property will yield a non-nil dictionary reflecting the settings used by the AVCaptureSession's current sessionPreset.
     
        On iOS, the only supported key is kCVPixelBufferPixelFormatTypeKey. Supported pixel formats are kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange, kCVPixelFormatType_420YpCbCr8BiPlanarFullRange and kCVPixelFormatType_32BGRA.
     */
    dataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    dataOutput.alwaysDiscardsLateVideoFrames = YES;
    [dataOutput setSampleBufferDelegate:self queue:_dataOutputQueue];
    if ([_captureSession canAddOutput:dataOutput]) {
        [_captureSession addOutput:dataOutput];
    }
    
    //加上这几句可以解决摄像头旋转的问题，但是貌似更常用的做法是在shader中做一次旋转
    _videoConnection = [dataOutput connectionWithMediaType:AVMediaTypeVideo];
    _videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    _videoConnection.videoMirrored = YES;
    
    int frameRate = 30;
    NSString *sessionPreset = AVCaptureSessionPresetHigh;
    CMTime frameDuration = kCMTimeInvalid;
    
    if ([NSProcessInfo processInfo].processorCount == 1) {
        sessionPreset = AVCaptureSessionPreset640x480;
        frameRate = 15;
    }
    
    if ([_captureSession canSetSessionPreset:sessionPreset]) {
        [_captureSession setSessionPreset:sessionPreset];
    }
    
    frameDuration = CMTimeMake(1, frameRate);
    NSError *error = nil;
    if ([frontDevice lockForConfiguration:&error]) {
        frontDevice.activeVideoMaxFrameDuration = frameDuration;
        frontDevice.activeVideoMinFrameDuration = frameDuration;
        [frontDevice unlockForConfiguration];
    } else {
        NSLog(@"error is %@", error);
    }
    
    
}

#pragma mark - PublicMethod

- (void)startRunning {
    dispatch_sync(_sessionQueue, ^{
        [self setupCaptureSession];
        if (_captureSession) {
            [_captureSession startRunning];
        }
    });
}

- (void)stopRunning {
    dispatch_sync(_sessionQueue, ^{
        if (_captureSession) {
            [_captureSession stopRunning];
        }
    });
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
//    NSLog(@"sampleBuffer is %@", sampleBuffer);
    if ([self.delegate respondsToSelector:@selector(capturePipline:didOutputSampleBuffer:)]) {
        [self.delegate capturePipline:self didOutputSampleBuffer:sampleBuffer];
    }
}




@end
