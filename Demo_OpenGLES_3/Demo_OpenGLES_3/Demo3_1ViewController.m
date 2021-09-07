//
//  Demo3_1ViewController.m
//  Demo_OpenGLES_3
//
//  Created by billthaslu on 2021/9/7.
//

#import "Demo3_1ViewController.h"
#import "DemoCapturePipline.h"
#import <AVFoundation/AVFoundation.h>

@interface Demo3_1ViewController ()

@property (nonatomic, strong) DemoCapturePipline *pipeline;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation Demo3_1ViewController

- (void)dealloc {
    [_pipeline stopRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pipeline = [[DemoCapturePipline alloc] init];
    
    [_pipeline startRunning];
    
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_pipeline.captureSession];
    _previewLayer.frame = self.view.bounds;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:_previewLayer];
}




@end
