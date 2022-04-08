//
//  Demo4_1ViewController.m
//  Demo_OpenGLES_4
//
//  Created by billthaslu on 2022/2/10.
//

#import "Demo4_1ViewController.h"
#import "DemoGLKit.h"

@interface Demo4_1ViewController ()

@property (nonatomic, strong) DemoGLVideoCamera *videoCamera;
@property (nonatomic, strong) DemoGLView *glView;
@property (nonatomic, strong) DemoGLView *glView2;

@end

@implementation Demo4_1ViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
    [EAGLContext setCurrentContext:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _videoCamera = [[DemoGLVideoCamera alloc] init];
    [_videoCamera setupAVCaptureConnectionWithBlock:^(AVCaptureConnection * _Nonnull connection) {
        connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        connection.videoMirrored = YES;
    }];
    
    _glView = [[DemoGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
    
    [_videoCamera addTarget:_glView];
    
    
//    _glView2 = [[DemoGLView alloc] initWithFrame:CGRectMake(200, 100, 90, 160)];
//    [self.view addSubview:_glView2];
//    [_videoCamera addTarget:_glView2];
    
    
    [_videoCamera startCameraCapture];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.glView.frame = self.view.bounds;//这一句要放到修改transform之后，因为glView修改frame的时候才会重新创建frameBuffer
}


@end
