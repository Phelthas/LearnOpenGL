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
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;

@end

@implementation Demo4_1ViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cameraPosition = AVCaptureDevicePositionFront;
    
    _videoCamera = [[DemoGLVideoCamera alloc] initWithCameraPosition:self.cameraPosition];
    
    _glView = [[DemoGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
    
    [_videoCamera addTarget:_glView];
    
    [_videoCamera startCameraCapture];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (self.cameraPosition == AVCaptureDevicePositionFront) {
        CGFloat degree = [Demo4_1ViewController degreeToRoateForFrontCameraWithOrientation:deviceOrientation];
        CATransform3D transform;
        transform = CATransform3DMakeScale(-1, 1, 1);
        transform = CATransform3DRotate(transform, degree / 360 * 2 * M_PI, 0, 0, 1);
        self.glView.layer.transform = transform;
    } else {
        CGFloat degree = [Demo4_1ViewController degreeToRoateForBackCameraWithOrientation:deviceOrientation];
        CATransform3D transform;
        transform = CATransform3DMakeRotation(degree / 360 * 2 * M_PI, 0, 0, 1);
        self.glView.layer.transform = transform;
    }
    self.glView.frame = self.view.bounds;//这一句要放到修改transform之后，因为glView修改frame的时候才会重新创建frameBuffer
}

+ (CGFloat)degreeToRoateForFrontCameraWithOrientation:(UIInterfaceOrientation)orientation {
    //前置摄像头情况下
    CGFloat degree = 0;
    if (orientation == UIInterfaceOrientationPortrait) {
        //orientation = 1
        degree = 90;
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        //orientation = 2
        degree = 270;
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        //orientation = 3
        degree = 180;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        //orientation = 4
        degree = 0;
    }
    return degree;
}

+ (CGFloat)degreeToRoateForBackCameraWithOrientation:(UIInterfaceOrientation)orientation {
    //后置摄像头情况下
    CGFloat degree = 0;
    if (orientation == UIInterfaceOrientationPortrait) {
        //orientation = 1
        degree = 90;
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        //orientation = 2
        degree = 270;
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        //orientation = 3
        degree = 0;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        //orientation = 4
        degree = 180;
    }
    return degree;
}


@end
