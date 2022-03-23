//
//  Demo6_4ViewController.m
//  Demo_OpenGLES_6
//
//  Created by lu xiaoming on 2022/3/22.
//

#import "Demo6_4ViewController.h"
#import "DemoGLKit.h"


@interface Demo6_4ViewController ()

@property (nonatomic, strong) DemoGLVideoCamera *cameraOutput;
@property (nonatomic, strong) DemoGLPicture *pictureOutput;
@property (nonatomic, strong) DemoGLView *glView;

@end

@implementation Demo6_4ViewController

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
    
    
    _glView = [[DemoGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
    
    DemoGLMultiDrawFilter *twoDrawFilter = [[DemoGLMultiDrawFilter alloc] init];
    [twoDrawFilter setupWithShouldBlend:YES];
    [twoDrawFilter setupWithBackgroundColor:[UIColor colorWithRed:0 green:1 blue:1 alpha:0.5]];
    [twoDrawFilter setupWithTexture2Frame:CGRectMake(100, 100, 100, 100) superViewSize:self.view.bounds.size];
    
    [_cameraOutput addTarget:twoDrawFilter];
    [_pictureOutput addTarget:twoDrawFilter];
    
    [twoDrawFilter addTarget:_glView];
    
    
    [_cameraOutput startCameraCapture];
    [_pictureOutput processImage];
    
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.glView.frame = self.view.bounds;//这一句要放到修改transform之后，因为glView修改frame的时候才会重新创建frameBuffer
}




@end
