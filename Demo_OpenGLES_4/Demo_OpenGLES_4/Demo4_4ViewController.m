//
//  Demo4_4ViewController.m
//  Demo_OpenGLES_4
//
//  Created by billthaslu on 2022/2/19.
//

#import "Demo4_4ViewController.h"
#import "DemoGLKit.h"
#import <LXMKit.h>
#import "Demo4GLView.h"


@interface Demo4_4ViewController ()

@property (nonatomic, strong) DemoGLVideoCamera *videoCamera;
@property (nonatomic, strong) Demo4GLView *glView;
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
        CATransform3D transform = CATransform3DIdentity;
        //注意：矩阵乘法不遵守交换律，先旋转再缩放，跟先缩放再旋转，效果是不一样的！！！常规做法都是先缩放再旋转
        transform = CATransform3DRotate(transform, degree / 360 * 2 * M_PI, 0, 0, 1);
        transform = CATransform3DScale(transform, -1, 1, 1);
        
        self.glView.zDegree = degree;
        self.glView.yDegree = 180;
        
    } else {
        CGFloat degree = [LXMCameraGeometry degreeToRoateForCameraWithVideoOrientation:self.videoOrientation interfaceOrientation:deviceOrientation isFrontCamera:NO];
        
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, degree / 360 * 2 * M_PI, 0, 0, 1);
        
        self.glView.zDegree = degree;
    }
    
}

@end
