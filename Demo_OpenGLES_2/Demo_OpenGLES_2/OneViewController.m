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

- (void)dealloc {
    LogClassAndFunction;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupGLView];
    
    
    [_glView setupProgramAndViewport];
    [_glView displayContent];
    
}

- (void)setupGLView {
    _glView = [[DemoGLView alloc] initWithFrame:self.view.bounds];
    [_glView loadShaders];
    [self.view addSubview:_glView];
}

@end
