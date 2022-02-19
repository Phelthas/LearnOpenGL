//
//  Demo4_TestViewController.m
//  Demo_OpenGLES_4
//
//  Created by billthaslu on 2022/2/19.
//

#import "Demo4_TestViewController.h"
#import "LXMKit.h"

@interface Demo4_TestViewController ()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation Demo4_TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    CGFloat width = self.view.frame.size.width;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 200, width, width)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.backgroundColor = UIColor.orangeColor;
    _imageView.image = [UIImage imageNamed:@"saber.jpeg"];
    [self.view addSubview:_imageView];

    CGFloat degree = 90;
    CATransform3D transform = CATransform3DIdentity;
    
//    transform = CATransform3DRotate(transform, degree / 360 * 2 * M_PI, 0, 0, 1);
    transform = CATransform3DScale(transform, -1, 1, 1);
//    transform = CATransform3DRotate(transform, 180.0 / 360 * 2 * M_PI, 0, 1, 0);
    
    logTransform3D(transform);
    
    _imageView.layer.transform = transform;
    
    
    [self testTransform];
    
    
}

- (void)testTransform {
    CGFloat degree = 30;
    CATransform3D transform = CATransform3DIdentity;
    
    transform = CATransform3DScale(transform, -1, 1, 1);
//    transform = CATransform3DRotate(transform, degree / 360 * 2 * M_PI, 0, 0, 1);
//    transform = CATransform3DRotate(transform, 180 / 360 * 2 * M_PI, 0, 1, 0);
    
    CATransform3D t1 = transform;
    
    
    
    transform = CATransform3DIdentity;
    // 这里写成 180 / 360 * 2 * M_PI 结果会是0.。。。。。坑了自己半天
    transform = CATransform3DRotate(transform, 2 * M_PI * 180 / 360 , 0, 1, 0);
//    transform = CATransform3DRotate(transform, degree / 360 * 2 * M_PI, 0, 0, 1);
//    transform1 = CATransform3DScale(transform1, -1, 1, 1);
    
    CATransform3D t2 = transform;
    
    CGFloat radius = degree / 360 * 2 * M_PI;
    CGFloat s = sin(radius);
    CGFloat c = cos(radius);

    GLfloat rotateZMatrix[] = {
        c, s, 0, 0,
        -s, c, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
    };
    
    bool result = CATransform3DEqualToTransform(t1, t2);
    
    logTransform3D(t1);
    logTransform3D(t2);
    
}

@end
