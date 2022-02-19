//
//  Demo4_4ViewController.m
//  Demo_OpenGLES_4
//
//  Created by billthaslu on 2022/2/19.
//

#import "Demo4_4ViewController.h"
#import "DemoGLKit.h"
#import <LXMKit.h>
#import "Demo4_4GLView.h"


@interface Demo4_4ViewController ()

@property (nonatomic, strong) DemoGLVideoCamera *videoCamera;
@property (nonatomic, strong) Demo4_4GLView *glView;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;


@end

@implementation Demo4_4ViewController

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
    
    
    _glView = [[Demo4_4GLView alloc] initWithFrame:self.view.bounds];
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
        self.glView.rotateMatrix = CATransform3DMakeRotation(degree * 2 * M_PI / 360, 0, 0, 1);
        self.glView.scaleMatrix = CATransform3DMakeScale(-1, 1, 1);
        
    } else {
        CGFloat degree = [LXMCameraGeometry degreeToRoateForCameraWithVideoOrientation:self.videoOrientation interfaceOrientation:deviceOrientation isFrontCamera:NO];
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, degree * 2 * M_PI / 360, 0, 0, 1);
        self.glView.rotateMatrix = transform;
    }
    
}

@end
