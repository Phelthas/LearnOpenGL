//
//  Demo6_1ViewController.m
//  Demo_OpenGLES_6
//
//  Created by lu xiaoming on 2022/3/18.
//

#import "Demo6_1ViewController.h"
#import "DemoGLKit.h"


@interface Demo6_1ViewController ()

@property (nonatomic, strong) DemoGLPicture *pictureOutput;
@property (nonatomic, strong) LXMDemoGLView *glView;

@end

@implementation Demo6_1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _glView = [[LXMDemoGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
    
    
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"saber" ofType:@"jpeg"];//1280*1024
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"xianhua" ofType:@"png"];// 64*64
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    _pictureOutput = [[DemoGLPicture alloc] initWithImage:image];
    
    
    BOOL useFilter = YES;
    if (useFilter) {
        DemoGLTestFilter *filter = [[DemoGLTestFilter alloc] init];
        [filter setupWithBackgroundColor:[UIColor colorWithRed:0 green:1 blue:1 alpha:0.5]];
        [filter setupWithShouldBlend:YES];
        
        [_pictureOutput addTarget:filter];
        [filter addTarget:_glView];
    } else {
        [_pictureOutput addTarget:_glView];
    }
    
    [_pictureOutput processImage];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.glView.frame = self.view.bounds;//这一句要放到修改transform之后，因为glView修改frame的时候才会重新创建frameBuffer
}

- (void)handleTimer:(NSTimer *)timer {
    [self.pictureOutput processImage];
}


@end
