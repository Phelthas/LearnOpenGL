//
//  Demo6_3ViewController.m
//  Demo_OpenGLES_6
//
//  Created by lu xiaoming on 2022/3/22.
//

#import "Demo6_3ViewController.h"
#import "DemoGLKit.h"


@interface Demo6_3ViewController ()

@property (nonatomic, strong) DemoGLVideoCamera *cameraOutput;
@property (nonatomic, strong) DemoGLPicture *pictureOutput;
@property (nonatomic, strong) LXMDemoGLView *glView;

@end

@implementation Demo6_3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    _cameraOutput = [[DemoGLVideoCamera alloc] initWithCameraPosition:AVCaptureDevicePositionFront];
    [_cameraOutput setupAVCaptureConnectionWithBlock:^(AVCaptureConnection * _Nonnull connection) {
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        connection.videoMirrored = YES;
    }];
    
    
    //    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"saber" ofType:@"jpeg"];//1280*1024
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"xianhua" ofType:@"png"];// 64*64
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        
        _pictureOutput = [[DemoGLPicture alloc] initWithImage:image];
    
    
    _glView = [[LXMDemoGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
    
    DemoGLTwoInputFilter *twoInputFilter = [[DemoGLTwoInputFilter alloc] init];
    [twoInputFilter setupWithBackgroundColor:[UIColor colorWithRed:0 green:1 blue:1 alpha:0.5]];
    [twoInputFilter setupWithShouldBlend:NO];
    
    DemoGLFilter *filter = [[DemoGLFilter alloc] init];
    
    [_cameraOutput addTarget:twoInputFilter];
    [_pictureOutput addTarget:filter];
    [filter addTarget:twoInputFilter];
    
    [twoInputFilter addTarget:_glView];
    
    
    [_cameraOutput startCameraCapture];
    [_pictureOutput processImage];
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.glView.frame = self.view.bounds;//这一句要放到修改transform之后，因为glView修改frame的时候才会重新创建frameBuffer
}




@end
