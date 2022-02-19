//
//  Demo4_3ViewController.m
//  Demo_OpenGLES_4
//
//  Created by billthaslu on 2022/2/18.
//

#import "Demo4_3ViewController.h"
#import "DemoGLKit.h"
#import <LXMKit.h>
#import "Demo4GLView.h"


@interface Demo4_3ViewController ()

@property (nonatomic, strong) DemoGLVideoCamera *videoCamera;
@property (nonatomic, strong) Demo4GLView *glView;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;


@end

@implementation Demo4_3ViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cameraPosition = AVCaptureDevicePositionFront;
    self.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    __weak typeof(self)weakSelf = self;
    _videoCamera = [[DemoGLVideoCamera alloc] initWithCameraPosition:self.cameraPosition];
    [_videoCamera setupAVCaptureConnectionWithBlock:^(AVCaptureConnection * _Nonnull connection) {
        //设置为AVCaptureVideoOrientationPortrait，输出的sampleBuffer宽高就会变成720*1280
        connection.videoOrientation = weakSelf.videoOrientation;
    }];
    
    
    _glView = [[Demo4GLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
    
    [_videoCamera addTarget:_glView];
    
    [_videoCamera startCameraCapture];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self updateVertexMatrix];
    self.glView.frame = self.view.bounds;//这一句要放到修改transform之后，因为glView修改frame的时候才会重新创建frameBuffer
}

- (void)updateVertexMatrix {
    UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    if (self.cameraPosition == AVCaptureDevicePositionFront) {
        CGFloat degree = [LXMCameraGeometry degreeToRoateForCameraWithVideoOrientation:self.videoOrientation interfaceOrientation:deviceOrientation isFrontCamera:YES];
        self.glView.zDegree = degree;
        self.glView.yDegree = 180;
        
    } else {
        CGFloat degree = [LXMCameraGeometry degreeToRoateForCameraWithVideoOrientation:self.videoOrientation interfaceOrientation:deviceOrientation isFrontCamera:NO];
        self.glView.zDegree = degree;
    }
    
}

@end
