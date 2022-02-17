//
//  Demo4_2ViewController.m
//  Demo_OpenGLES_4
//
//  Created by billthaslu on 2022/2/17.
//

#import "Demo4_2ViewController.h"
#import "DemoGLKit.h"

@interface Demo4_2ViewController ()

@property (nonatomic, strong) DemoGLVideoCamera *videoCamera;
@property (nonatomic, strong) DemoGLView *glView;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;

@end

@implementation Demo4_2ViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cameraPosition = AVCaptureDevicePositionFront;
    
    _videoCamera = [[DemoGLVideoCamera alloc] initWithCameraPosition:self.cameraPosition];
    [_videoCamera setupAVCaptureConnectionWithBlock:^(AVCaptureConnection * _Nonnull connection) {
//        //设置为AVCaptureVideoOrientationPortrait，输出的sampleBuffer宽高就会变成720*1280
//        connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
//        connection.videoMirrored = NO;
    }];
    
    
    _glView = [[DemoGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
    
    [_videoCamera addTarget:_glView];
    
    [_videoCamera startCameraCapture];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;

    if (self.cameraPosition == AVCaptureDevicePositionFront) {
        CGFloat degree = [Demo4_2ViewController degreeToRoateForFrontCameraWithOrientation:deviceOrientation];
        CATransform3D transform = CATransform3DIdentity;
        //注意：矩阵乘法不遵守交换律，先旋转再缩放，跟先缩放再旋转，效果是不一样的！！！常规做法都是先缩放再旋转
        transform = CATransform3DScale(transform, -1, 1, 1);
        transform = CATransform3DRotate(transform, degree / 360 * 2 * M_PI, 0, 0, 1);
        self.glView.layer.transform = transform;
    } else {
        CGFloat degree = [Demo4_2ViewController degreeToRoateForBackCameraWithOrientation:deviceOrientation];
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, degree / 360 * 2 * M_PI, 0, 0, 1);
        self.glView.layer.transform = transform;
    }
    self.glView.frame = self.view.bounds;//这一句要放到修改transform之后，因为glView修改frame的时候才会重新创建frameBuffer
}


/**
 顺时针或逆时针旋转180度等于先作一个水平镜像,再作一个垂直镜像；
 对于前置摄像头来说，
 设置videoOrientation = AVCaptureVideoOrientationLandscapeLeft，输出的image会逆时针旋转90度，看起来图片就是往左倒了；
 设置videoOrientation = AVCaptureVideoOrientationLandscapeRight，输出的image会顺时针旋转90度，看起来图片就是往右倒了；
 
 对于后置摄像头来说，
 设置videoOrientation = AVCaptureVideoOrientationLandscapeLeft，输出的image会顺时针旋转90度，看起来图片就是往右倒了；
 设置videoOrientation = AVCaptureVideoOrientationLandscapeRight，输出的image会逆时针旋转90度，看起来图片就是往左倒了；
 */
+ (CGFloat)degreeToRoateForFrontCameraWithOrientation:(UIInterfaceOrientation)orientation {
    //前置摄像头情况下,没有设置videoOrientation，所以此时videoOrientation = AVCaptureVideoOrientationLandscapeLeft
    CGFloat degree = 0;
    if (orientation == UIInterfaceOrientationPortrait) {
        //orientation = 1
        degree = 90;
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        //orientation = 2
        degree = 270;
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {//home button on the right
        //orientation = 3
        degree = 180;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {//home button on the left
        //orientation = 4
        degree = 0;
    }
    return degree;
}

+ (CGFloat)degreeToRoateForBackCameraWithOrientation:(UIInterfaceOrientation)orientation {
    //后置摄像头情况下,没有设置videoOrientation，所以此时videoOrientation = AVCaptureVideoOrientationLandscapeRight
    CGFloat degree = 0;
    if (orientation == UIInterfaceOrientationPortrait) {
        //orientation = 1
        degree = 90;
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        //orientation = 2
        degree = 270;
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {//home button on the right
        //orientation = 3
        degree = 0;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {//home button on the left
        //orientation = 4
        degree = 180;
    }
    return degree;
}


@end
