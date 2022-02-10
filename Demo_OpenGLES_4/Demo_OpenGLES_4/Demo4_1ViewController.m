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


@end

@implementation Demo4_1ViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _videoCamera = [[DemoGLVideoCamera alloc] init];
    
    _glView = [[DemoGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
    
    [_videoCamera addTarget:_glView];
    
    [_videoCamera startCameraCapture];
    
}


@end
