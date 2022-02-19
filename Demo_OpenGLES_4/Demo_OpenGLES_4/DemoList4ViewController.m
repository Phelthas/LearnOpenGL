//
//  DemoList4ViewController.m
//  Demo_OpenGLES_4
//
//  Created by billthaslu on 2022/2/10.
//

#import "DemoList4ViewController.h"

@interface DemoList4ViewController ()

@end

@implementation DemoList4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"DemoList4";
    
    self.dataArray = @[
        [LXMDemoEntranceModel entranceModelWithName:@"Demo4_TestViewController"],
        [LXMDemoEntranceModel entranceModelWithName:@"Demo4_1ViewController" desc:@"无方向修正"],
        [LXMDemoEntranceModel entranceModelWithName:@"Demo4_2ViewController" desc:@"使用Layer.transform修正方向"],
        [LXMDemoEntranceModel entranceModelWithName:@"Demo4_3ViewController" desc:@"通过顶点坐标修正方向"],
        [LXMDemoEntranceModel entranceModelWithName:@"Demo4_4ViewController"],
        
    ];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
