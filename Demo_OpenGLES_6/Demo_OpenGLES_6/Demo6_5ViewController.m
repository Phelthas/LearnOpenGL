//
//  Demo6_5ViewController.m
//  Demo_OpenGLES_6
//
//  Created by lu xiaoming on 2022/3/24.
//

#import "Demo6_5ViewController.h"
#import "DemoGLKit.h"


@interface Demo6_5ViewController ()

@property (nonatomic, strong) DemoGLVideoCamera *cameraOutput;
@property (nonatomic, strong) DemoGLPicture *pictureOutput;
@property (nonatomic, strong) LXMDemoGLView *glView;

@end

@implementation Demo6_5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    _cameraOutput = [[DemoGLVideoCamera alloc] initWithCameraPosition:AVCaptureDevicePositionFront];
    [_cameraOutput setupAVCaptureConnectionWithBlock:^(AVCaptureConnection * _Nonnull connection) {
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        connection.videoMirrored = YES;
    }];
    
    BOOL useImageArray = YES;
    if (useImageArray) {
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < 72; i++) {
            NSString *imageName = [NSString stringWithFormat:@"F_MouceHeart_%03d", i];
            UIImage *image = [UIImage imageNamed:imageName];
            [array addObject:image];
        }
        _pictureOutput = [[DemoGLPicture alloc] initWithImageArray:array];
    } else {
        //    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"saber" ofType:@"jpeg"];//1280*1024
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"xianhua" ofType:@"png"];// 64*64
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
        _pictureOutput = [[DemoGLPicture alloc] initWithImage:image];
    }
    
    _glView = [[LXMDemoGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
    
    DemoGLStickerFilter *stickerFilter = [[DemoGLStickerFilter alloc] initWithGLPicture:_pictureOutput];
    [stickerFilter setupWithShouldBlend:YES];
    [stickerFilter setupWithTexture2Frame:CGRectMake(100, 100, 100, 75) superViewSize:self.view.bounds.size];
    
    [_cameraOutput addTarget:stickerFilter];

    [stickerFilter addTarget:_glView];
    
    [_cameraOutput startCameraCapture];
        
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.glView.frame = self.view.bounds;//这一句要放到修改transform之后，因为glView修改frame的时候才会重新创建frameBuffer
}




@end
