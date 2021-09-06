//
//  DemoList2ViewController.m
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/6/14.
//

#import "DemoList2ViewController.h"


@interface DemoList2ViewController ()

@end

@implementation DemoList2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"DemoList2";
    
    self.dataArray = @[
        [LXMDemoEntranceModel entranceModelWithName:@"OneViewController"],
        [LXMDemoEntranceModel entranceModelWithName:@"TwoViewController" desc:@"用 手动修改顶点 的方式修复图形被拉伸的问题"],
        [LXMDemoEntranceModel entranceModelWithName:@"Two_2ViewController" desc:@"用 投影矩阵 的方式修复图形被拉伸的问题"],
        [LXMDemoEntranceModel entranceModelWithName:@"ThreeViewController" desc:nil],
        [LXMDemoEntranceModel entranceModelWithName:@"Three_2ViewController" desc:nil],
        [LXMDemoEntranceModel entranceModelWithName:@"Three_3ViewController" desc:nil],
        [LXMDemoEntranceModel entranceModelWithName:@"FourViewController" desc:nil],
        [LXMDemoEntranceModel entranceModelWithName:@"FiveViewController" desc:nil],
    ];
    
}



@end
