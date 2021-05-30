//
//  DemoCapturePipline.m
//  Demo_VideoCapture
//
//  Created by billthaslu on 2021/5/30.
//

#import "DemoCapturePipline.h"

@interface DemoCapturePipline ()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
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

    [dataOutput setSampleBufferDelegate:self queue:_dataOutputQueue];
    if ([_captureSession canAddOutput:dataOutput]) {
        [_captureSession addOutput:dataOutput];
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
    AVCaptureVideoDataOutput *dataOutput = (AVCaptureVideoDataOutput *)output;
    NSDictionary *dict = dataOutput.videoSettings;
    NSLog(@"dataOutput.videoSettings is \n %@", dict);
    /**
     iPhoneX上的默认值
     Height = 1080;
     PixelFormatType = 875704438; //即kCVPixelFormatType_422YpCbCr8BiPlanarVideoRange = '420v'
     Width = 1920;
     '420v'是c++的语法 单引号字符串，其值是 '4' << 24  + '2' << 16 + '0' << 8 + 'v'
     其中 int('0')=48, int('a')=97, int('A')=65
     */
    
//    NSLog(@"sampleBuffer is %@", sampleBuffer);

}




@end
