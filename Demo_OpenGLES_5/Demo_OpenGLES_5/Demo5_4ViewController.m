//
//  Demo5_4ViewController.m
//  Demo_OpenGLES_5
//
//  Created by lu xiaoming on 2022/3/11.
//

#import "Demo5_4ViewController.h"
#import "DemoGLKit.h"
#import "Demo5GLView.h"
#import "DemoGLVideoCamera4.h"


@interface Demo5_4ViewController ()

@property (nonatomic, strong) DemoGLVideoCamera4 *videoCamera;
@property (nonatomic, strong) Demo5GLView *glView;
@property (nonatomic, strong) Demo5GLView *glView2;

@end

@implementation Demo5_4ViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    [EAGLContext setCurrentContext:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _videoCamera = [[DemoGLVideoCamera4 alloc] init];
    [_videoCamera setupAVCaptureConnectionWithBlock:^(AVCaptureConnection * _Nonnull connection) {
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        connection.videoMirrored = YES;
    }];
    
    _glView = [[Demo5GLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
    
    [_videoCamera addTarget:_glView];
    
    
//    _glView2 = [[Demo5GLView alloc] initWithFrame:CGRectMake(200, 100, 90, 160)];
//    [self.view addSubview:_glView2];
//    [_videoCamera addTarget:_glView2];
    
    
    [_videoCamera startCameraCapture];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.glView.frame = self.view.bounds;//这一句要放到修改transform之后，因为glView修改frame的时候才会重新创建frameBuffer
}

@end
