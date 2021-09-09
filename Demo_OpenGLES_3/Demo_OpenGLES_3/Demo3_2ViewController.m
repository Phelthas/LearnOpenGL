//
//  Demo3_2ViewController.m
//  Demo_OpenGLES_3
//
//  Created by billthaslu on 2021/9/7.
//

#import "Demo3_2ViewController.h"
#import "DemoCapturePipline.h"
#import "Demo3GLView.h"


@interface Demo3_2ViewController ()<DemoCapturePiplineDelegate>

@property (nonatomic, strong) DemoCapturePipline *pipeline;
@property (nonatomic, strong) Demo3GLView *glView;


@end

@implementation Demo3_2ViewController

- (void)dealloc {
    [_pipeline stopRunning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _pipeline = [[DemoCapturePipline alloc] init];
    _pipeline.delegate = self;
    [_pipeline startRunning];
    
    _glView = [[Demo3GLView alloc] initWithFrame:self.view.bounds vertexShaderFileName:@"DemoPositionCorodinate.vsh" fragmentShaderFileName:@"DemoTexturePassThrough.fsh"];
   
}

#pragma mark - DemoCapturePiplineDelegate

- (void)capturePipline:(DemoCapturePipline *)capturePipline didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    
}


@end
