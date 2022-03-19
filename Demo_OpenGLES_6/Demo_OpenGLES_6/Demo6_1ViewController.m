//
//  Demo6_1ViewController.m
//  Demo_OpenGLES_6
//
//  Created by lu xiaoming on 2022/3/18.
//

#import "Demo6_1ViewController.h"
#import "DemoGLKit.h"
#import "DemoGLView.h"


@interface Demo6_1ViewController ()

@property (nonatomic, strong) DemoGLPicture *pictureOutput;
@property (nonatomic, strong) DemoGLView *glView;
@property (nonatomic, strong) DemoGLView *glView2;

@end

@implementation Demo6_1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"saber" ofType:@"jpeg"];//1280*1024
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"xianhua" ofType:@"png"];// 64*64
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    
    _pictureOutput = [[DemoGLPicture alloc] initWithImage:image];
    
    
    _glView = [[DemoGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
    
    [_pictureOutput addTarget:_glView];
    
    
//    _glView2 = [[DemoGLView alloc] initWithFrame:CGRectMake(200, 100, 90, 160)];
//    [self.view addSubview:_glView2];
//    [_pictureOutput addTarget:_glView2];
    
    
    [_pictureOutput processImage];
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.glView.frame = self.view.bounds;//这一句要放到修改transform之后，因为glView修改frame的时候才会重新创建frameBuffer
}


@end
