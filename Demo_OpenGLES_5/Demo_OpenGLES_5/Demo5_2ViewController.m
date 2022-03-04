//
//  Demo5_2ViewController.m
//  Demo_OpenGLES_5
//
//  Created by billthaslu on 2022/3/4.
//

#import "Demo5_2ViewController.h"
#import "DemoGLKit.h"
#import "Demo5GLView.h"
#import "DemoGLI420Camera2.h"


@interface Demo5_2ViewController ()

@property (nonatomic, strong) DemoGLI420Camera2 *i420Camera;
@property (nonatomic, strong) Demo5GLView *glView;
@property (nonatomic, strong) Demo5GLView *glView2;

@end

@implementation Demo5_2ViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    [EAGLContext setCurrentContext:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _i420Camera = [[DemoGLI420Camera2 alloc] init];
    [_i420Camera setupAVCaptureConnectionWithBlock:^(AVCaptureConnection * _Nonnull connection) {
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        connection.videoMirrored = YES;
    }];
    
    _glView = [[Demo5GLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
    
    [_i420Camera addTarget:_glView];
    
    
//    _glView2 = [[Demo5GLView alloc] initWithFrame:CGRectMake(200, 100, 90, 160)];
//    [self.view addSubview:_glView2];
//    [_i420Camera addTarget:_glView2];
    
    
    [_i420Camera startCameraCapture];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.glView.frame = self.view.bounds;//这一句要放到修改transform之后，因为glView修改frame的时候才会重新创建frameBuffer
}

@end

