//
//  Demo6_2ViewController.m
//  Demo_OpenGLES_6
//
//  Created by lu xiaoming on 2022/3/21.
//

#import "Demo6_2ViewController.h"
#import "DemoGLKit.h"


@interface Demo6_2ViewController ()

@property (nonatomic, strong) DemoGLVideoCamera *cameraOutput;
@property (nonatomic, strong) LXMDemoGLView *glView;

@end

@implementation Demo6_2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _glView = [[LXMDemoGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
        
    _cameraOutput = [[DemoGLVideoCamera alloc] initWithCameraPosition:AVCaptureDevicePositionFront];
    [_cameraOutput setupAVCaptureConnectionWithBlock:^(AVCaptureConnection * _Nonnull connection) {
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        connection.videoMirrored = YES;
    }];
    
    BOOL useFilter = YES;
    if (useFilter) {
//        DemoGLTestFilter *filter = [[DemoGLTestFilter alloc] init];
        DemoGLRoundRectFilter *filter = [[DemoGLRoundRectFilter alloc] init];
        [filter setupWithBackgroundColor:[UIColor colorWithRed:0 green:1 blue:1 alpha:0.5]];
        [filter setupWithShouldBlend:YES];
        
        [_cameraOutput addTarget:filter];
        [filter addTarget:_glView];
    } else {
        [_cameraOutput addTarget:_glView];
    }
    
    
    
    
    [_cameraOutput startCameraCapture];
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.glView.frame = self.view.bounds;//这一句要放到修改transform之后，因为glView修改frame的时候才会重新创建frameBuffer
}




@end
