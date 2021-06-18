//
//  OneViewController.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/6/14.
//

#import "OneViewController.h"
#import "DemoGLView.h"

@interface OneViewController ()

@property (nonatomic, strong) DemoGLView *glView;

@end

@implementation OneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _glView = [[DemoGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_glView];
    
    [_glView loadShaders];
    [_glView initializeBuffer];
    [_glView displayContent];
    
}

@end
