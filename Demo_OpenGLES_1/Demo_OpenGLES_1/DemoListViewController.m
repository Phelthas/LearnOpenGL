//
//  DemoListViewController.m
//  Demo_OpenGLES_1
//
//  Created by billthaslu on 2021/5/31.
//  Copyright © 2021 lxm. All rights reserved.
//

#import "DemoListViewController.h"
#import "LXMDemoEntranceModel.h"

@interface DemoListViewController ()

@end

@implementation DemoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"DemoList";
    
    self.dataArray = @[
        [LXMDemoEntranceModel entranceModelWithName:@"OneViewController" desc:@"a simplest triangle"],
        [LXMDemoEntranceModel entranceModelWithName:@"TwoViewController" desc:@"a rectangle"],
        [LXMDemoEntranceModel entranceModelWithName:@"ThreeViewController" desc:@"draw a picture with GLKTextureLoader"],
        [LXMDemoEntranceModel entranceModelWithName:@"FourViewController" desc:@"draw a aspectScale picture with GLKTextureLoader"],
        [LXMDemoEntranceModel entranceModelWithName:@"FiveViewController" desc:@"create texture with CoreGraphics"],
        
    ];
    
}

@end
