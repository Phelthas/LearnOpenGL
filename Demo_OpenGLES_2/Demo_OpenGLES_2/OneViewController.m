//
//  OneViewController.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/6/14.
//

#import "OneViewController.h"
#import "DemoGLView.h"
#import "DemoGLView2.h"

@interface OneViewController ()

@property (nonatomic, strong) DemoGLView *glView;

@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self testGLView];
    [self testGLView2];
    
    [self.view addSubview:_glView];
    
    [_glView loadShaders];
    [_glView initializeBuffer];
    [_glView displayContent];
    
}

- (void)testGLView {
    _glView = [[DemoGLView alloc] initWithFrame:self.view.bounds];
}

- (void)testGLView2 {
    _glView = [[DemoGLView2 alloc] initWithFrame:self.view.bounds];
}

@end
