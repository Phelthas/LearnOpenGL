//
//  ViewController.m
//  Demo_Camera
//
//  Created by billthaslu on 2021/4/2.
//

#import "ViewController.h"
#import "DemoCapturePipline.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (nonatomic, strong) DemoCapturePipline *pipeline;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;


@end

@implementation ViewController

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
