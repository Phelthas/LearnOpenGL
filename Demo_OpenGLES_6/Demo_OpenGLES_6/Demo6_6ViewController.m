//
//  Demo6_6ViewController.m
//  Demo_OpenGLES_6
//
//  Created by lu xiaoming on 2022/3/26.
//

#import "Demo6_6ViewController.h"
#import "DemoGLKit.h"


@interface Demo6_6ViewController ()

@property (nonatomic, strong) DemoGLVideoCamera *cameraOutput;
@property (nonatomic, strong) DemoGLPicture *pictureOutput;
@property (nonatomic, strong) DemoGLView *glView;

@end

@implementation Demo6_6ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    _cameraOutput = [[DemoGLVideoCamera alloc] initWithCameraPosition:AVCaptureDevicePositionFront];
    [_cameraOutput setupAVCaptureConnectionWithBlock:^(AVCaptureConnection * _Nonnull connection) {
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
        connection.videoMirrored = YES;
    }];
    
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"heart" ofType:@"png"];// 1800*1200
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    _pictureOutput = [[DemoGLPicture alloc] initWithImage:image];
    
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"heart" ofType:@"json"];
    NSString *jsonContent = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
    
    DemoGLSpriteSheetModel *model = [DemoGLSpriteSheetModel modelWithSpriteSheetJson:jsonContent];
    
     
    _glView = [[DemoGLView alloc] initWithFrame:self.view.bounds];
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
