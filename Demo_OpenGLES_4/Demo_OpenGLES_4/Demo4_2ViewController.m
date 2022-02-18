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
@property (nonatomic, assign)AVCaptureVideoOrientation videoOrientation;


@end

@implementation Demo4_2ViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cameraPosition = AVCaptureDevicePositionBack;
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
    
    [_videoCamera startCameraCapture];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;

    if (self.cameraPosition == AVCaptureDevicePositionFront) {
        CGFloat degree = [Demo4_2ViewController degreeToRoateForFrontCameraWithInterfaceOrientation:deviceOrientation videoOrientation:self.videoOrientation];
        CATransform3D transform = CATransform3DIdentity;
        //注意：矩阵乘法不遵守交换律，先旋转再缩放，跟先缩放再旋转，效果是不一样的！！！常规做法都是先缩放再旋转
        transform = CATransform3DScale(transform, -1, 1, 1);
        transform = CATransform3DRotate(transform, degree / 360 * 2 * M_PI, 0, 0, 1);
        self.glView.layer.transform = transform;
    } else {
        CGFloat degree = [Demo4_2ViewController degreeToRoateForBackCameraWithInterfaceOrientation:deviceOrientation videoOrientation:self.videoOrientation];
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, degree / 360 * 2 * M_PI, 0, 0, 1);
        self.glView.layer.transform = transform;
    }
    
    self.glView.frame = self.view.bounds;//这一句要放到修改transform之后，因为glView修改frame的时候才会重新创建frameBuffer
}


/**
 顺时针或逆时针旋转180度等于先作一个水平镜像,再作一个垂直镜像；
 对于前置摄像头来说，videoOrientation 默认 AVCaptureVideoOrientationLandscapeLeft，
 此时将手机放到UIInterfaceOrientationLandscapeLeft时，采集的画面是正向的。
 设置videoOrientation = AVCaptureVideoOrientationLandscapeLeft，输出的image会逆时针旋转90度，看起来图片就是往左倒了；
 设置videoOrientation = AVCaptureVideoOrientationLandscapeRight，输出的image会顺时针旋转90度，看起来图片就是往右倒了；
 */
+ (CGFloat)degreeToRoateForFrontCameraWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation videoOrientation:(AVCaptureVideoOrientation)videoOrientation {
    CGFloat degree = 0;
    /*
    if (videoOrientation == AVCaptureVideoOrientationPortrait) {
        //videoOrientation = 1
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            //interfaceOrientation = 1
            degree = 0;
        } else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            //interfaceOrientation = 2
            degree = 180;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {//home button on the right
            //interfaceOrientation = 3
            degree = 90;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {//home button on the left
            //interfaceOrientation = 4
            degree = 270;
        }
    }
    else if (videoOrientation == AVCaptureVideoOrientationPortraitUpsideDown) {
        //videoOrientation = 2
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            //interfaceOrientation = 1
            degree = 180;
        } else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            //interfaceOrientation = 2
            degree = 0;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {//home button on the right
            //interfaceOrientation = 3
            degree = 270;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {//home button on the left
            //interfaceOrientation = 4
            degree = 90;
        }
        //可以看出，是在AVCaptureVideoOrientationPortrait结果的基础上，加了180
    }
    else if (videoOrientation == AVCaptureVideoOrientationLandscapeRight) {
        //videoOrientation = 3
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            //interfaceOrientation = 1
            degree = 270;
        } else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            //interfaceOrientation = 2
            degree = 90;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {//home button on the right
            //interfaceOrientation = 3
            degree = 0;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {//home button on the left
            //interfaceOrientation = 4
            degree = 180;
        }
        //可以看出，是在AVCaptureVideoOrientationPortrait结果的基础上，加了270
    }
    else if (videoOrientation == AVCaptureVideoOrientationLandscapeLeft) {
        //videoOrientation = 4
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            //interfaceOrientation = 1
            degree = 90;
        } else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            //interfaceOrientation = 2
            degree = 270;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {//home button on the right
            //interfaceOrientation = 3
            degree = 180;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {//home button on the left
            //interfaceOrientation = 4
            degree = 0;
        }
        //可以看出，是在AVCaptureVideoOrientationPortrait结果的基础上，加了90
    }
    */
     
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        //interfaceOrientation = 1
        degree = 0;
    } else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        //interfaceOrientation = 2
        degree = 180;
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {//home button on the right
        //interfaceOrientation = 3
        degree = 90;
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {//home button on the left
        //interfaceOrientation = 4
        degree = -90;
    }
    
    if (videoOrientation == AVCaptureVideoOrientationPortrait) {
        //videoOrientation = 1
    }
    else if (videoOrientation == AVCaptureVideoOrientationPortraitUpsideDown) {
        //videoOrientation = 2
        degree += 180;
    }
    else if (videoOrientation == AVCaptureVideoOrientationLandscapeRight) {
        //videoOrientation = 3
        degree += -90;
    }
    else if (videoOrientation == AVCaptureVideoOrientationLandscapeLeft) {
        //videoOrientation = 4
        degree += 90;
    }
    
    return degree;
}

/**
 对于后置摄像头来说，videoOrientation 默认 AVCaptureVideoOrientationLandscapeRight，
 此时将手机放到UIInterfaceOrientationLandscapeRight时，采集的画面是正向的。
 设置videoOrientation = AVCaptureVideoOrientationLandscapeLeft，输出的image会顺时针旋转90度，看起来图片就是往右倒了；
 设置videoOrientation = AVCaptureVideoOrientationLandscapeRight，输出的image会逆时针旋转90度，看起来图片就是往左倒了；
 */
+ (CGFloat)degreeToRoateForBackCameraWithInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation videoOrientation:(AVCaptureVideoOrientation)videoOrientation {
    //后置摄像头情况下
    CGFloat degree = 0;
    /*
     设置videoOrientation为什么，那么当interfaceOrientation也转到相同的方向时，画面就是正的；
     当interfaceOrientation为其他方向时，只需要相应的旋转摄像机的方向即可
    if (videoOrientation == AVCaptureVideoOrientationPortrait) {
        //videoOrientation = 1
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            //interfaceOrientation = 1
            degree = 0;
        } else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            //interfaceOrientation = 2
            degree = 180;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {//home button on the right
            //interfaceOrientation = 3
            degree = 270;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {//home button on the left
            //interfaceOrientation = 4
            degree = 90;
        }
    }
    else if (videoOrientation == AVCaptureVideoOrientationPortraitUpsideDown) {
        //videoOrientation = 2
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            //interfaceOrientation = 1
            degree = 180;
        } else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            //interfaceOrientation = 2
            degree = 0;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {//home button on the right
            //interfaceOrientation = 3
            degree = 90;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {//home button on the left
            //interfaceOrientation = 4
            degree = 270;
        }
        //可以看出，是在AVCaptureVideoOrientationPortrait结果的基础上，加了180
    }
    else if (videoOrientation == AVCaptureVideoOrientationLandscapeRight) {
        //videoOrientation = 3
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            //interfaceOrientation = 1
            degree = 90;
        } else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            //interfaceOrientation = 2
            degree = 270;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {//home button on the right
            //interfaceOrientation = 3
            degree = 0;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {//home button on the left
            //interfaceOrientation = 4
            degree = 180;
        }
        //可以看出，是在AVCaptureVideoOrientationPortrait结果的基础上，加了90
    }
    else if (videoOrientation == AVCaptureVideoOrientationLandscapeLeft) {
        //videoOrientation = 4
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            //interfaceOrientation = 1
            degree = 270;
        } else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            //interfaceOrientation = 2
            degree = 90;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {//home button on the right
            //interfaceOrientation = 3
            degree = 180;
        } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {//home button on the left
            //interfaceOrientation = 4
            degree = 0;
        }
        //可以看出，是在AVCaptureVideoOrientationPortrait结果的基础上，加了270
    }
    */
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait) {
        //interfaceOrientation = 1
        degree = 0;
    } else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        //interfaceOrientation = 2
        degree = 180;
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {//home button on the right
        //interfaceOrientation = 3
        degree = -90;
    } else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {//home button on the left
        //interfaceOrientation = 4
        degree = 90;
    }

    if (videoOrientation == AVCaptureVideoOrientationPortrait) {
        //videoOrientation = 1
    }
    else if (videoOrientation == AVCaptureVideoOrientationPortraitUpsideDown) {
        //videoOrientation = 2
        degree += 180;
    }
    else if (videoOrientation == AVCaptureVideoOrientationLandscapeRight) {
        //videoOrientation = 3
        degree += 90;
    }
    else if (videoOrientation == AVCaptureVideoOrientationLandscapeLeft) {
        //videoOrientation = 4
        degree += -90;
    }
    
    return degree;
}

@end
