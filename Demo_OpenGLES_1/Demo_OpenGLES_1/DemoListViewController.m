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
    
    self.dataArray = @[
        [LXMDemoEntranceModel entranceModelWithName:@"OneViewController" desc:@"a simplest triangle"],
        [LXMDemoEntranceModel entranceModelWithName:@"TwoViewController" desc:@"a rectangle"],
    ];
    
}

@end
