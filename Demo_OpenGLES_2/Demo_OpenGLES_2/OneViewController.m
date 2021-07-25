//
//  OneViewController.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/6/14.
//

#import "OneViewController.h"

@interface OneViewController ()

@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupGLView];
    
    
    [_glView loadShaders];
    [_glView initializeBuffer];
    [_glView displayContent];
    
}

- (void)setupGLView {
    _glView = [[DemoGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
}

@end
