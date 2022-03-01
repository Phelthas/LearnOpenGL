//
//  Demo4_2ViewController.m
//  Demo_OpenGLES_4
//
//  Created by billthaslu on 2022/2/17.
//

#import "Demo4_2ViewController.h"
#import "DemoGLKit.h"
#import <LXMKit.h>


@interface Demo4_2ViewController ()

@property (nonatomic, strong) DemoGLVideoCamera *videoCamera;
@property (nonatomic, strong) DemoGLView *glView;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;
@property (nonatomic, strong) DemoGLView *glView2;


@end

@implementation Demo4_2ViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cameraPosition = AVCaptureDevicePositionFront;
    self.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    
    __weak typeof(self)weakSelf = self;
    _videoCamera = [[DemoGLVideoCamera alloc] initWithCameraPosition:self.cameraPosition];
    [_videoCamera setupAVCaptureConnectionWithBlock:^(AVCaptureConnection * _Nonnull connection) {
//        //设置为AVCaptureVideoOrientationPortrait，输出的sampleBuffer宽高就会变成720*1280
        connection.videoOrientation = weakSelf.videoOrientation;
//        connection.videoMirrored = NO;
    }];
    
    
    _glView = [[DemoGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
    
    [_videoCamera addTarget:_glView];
    
//    _glView2 = [[DemoGLView alloc] initWithFrame:CGRectMake(200, 100, 90, 160)];
//    [self.view addSubview:_glView2];
//    [_videoCamera addTarget:_glView2];
    
    [_videoCamera startCameraCapture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    
    [self.view addGestureRecognizer:tapGesture];
    self.view.userInteractionEnabled = YES;
    
}

- (void)handleTapGesture {
    NSLog(@"handleTapGesture");
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;

    if (self.cameraPosition == AVCaptureDevicePositionFront) {
        CGFloat degree = [LXMCameraGeometry degreeToRoateForCameraWithVideoOrientation:self.videoOrientation interfaceOrientation:deviceOrientation isFrontCamera:YES];
        
        CATransform3D transform = CATransform3DIdentity;
        //注意：矩阵乘法不遵守交换律，先旋转再缩放，跟先缩放再旋转，效果是不一样的！！！常规做法都是先缩放再旋转
        transform = CATransform3DScale(transform, -1, 1, 1);
        //CATransform3D是行主序的，使用CATransform3Dxxx函数相当于左乘原来的矩阵！！！
        transform = CATransform3DRotate(transform, degree * 2 * M_PI / 360, 0, 0, 1);
        
        logTransform3D(transform);
        
        self.glView.layer.transform = transform;
        self.glView2.layer.transform = transform;
        //修改transform会导致frame也跟着变,但是修改frame，transform不会跟着变，注意
        self.glView2.frame = CGRectMake(200, 100, 90, 160);
    } else {
        CGFloat degree = [LXMCameraGeometry degreeToRoateForCameraWithVideoOrientation:self.videoOrientation interfaceOrientation:deviceOrientation isFrontCamera:NO];
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, degree * 2 * M_PI / 360, 0, 0, 1);
        self.glView.layer.transform = transform;
        self.glView2.layer.transform = transform;
        //修改transform会导致frame也跟着变,但是修改frame，transform不会跟着变，注意
        self.glView2.frame = CGRectMake(200, 100, 90, 160);
    }
    
    self.glView.frame = self.view.bounds;//这一句要放到修改transform之后，因为glView修改frame的时候才会重新创建frameBuffer
}

@end
