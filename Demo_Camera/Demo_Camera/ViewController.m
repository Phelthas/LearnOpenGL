//
//  ViewController.m
//  Demo_Camera
//
//  Created by billthaslu on 2021/4/2.
//

#import "ViewController.h"
#import "DemoCapturePipline.h"
#import <AVFoundation/AVFoundation.h>
#import "DemoTestGLView.h"

@interface ViewController ()<DemoCapturePiplineDelegate>

@property (nonatomic, strong) DemoCapturePipline *pipeline;
@property (nonatomic, strong) DemoTestGLView *glView;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    
    
    
    _pipeline = [[DemoCapturePipline alloc] init];
    _pipeline.delegate = self;
    
    [_pipeline startRunning];
    
    
    _glView = [[DemoTestGLView alloc] initWithFrame:self.view.bounds];
    [_glView loadShaders];
    [_glView initializeBuffer];
    [self.view addSubview:_glView];
    
    
    
    
}

#pragma mark - DemoCapturePiplineDelegate

- (void)capturePipline:(DemoCapturePipline *)capturePipline didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    static long frameID = 0;
    frameID++;
    CFRetain(sampleBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        [self.glView displayPixelBuffer:pixelBuffer];
//        NSLog(@"frameID:%@", @(frameID));
        CFRelease(sampleBuffer);
    });
}






@end
