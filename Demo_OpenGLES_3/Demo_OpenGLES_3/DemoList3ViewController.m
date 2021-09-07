//
//  DemoList3ViewController.m
//  Demo_OpenGLES_3
//
//  Created by billthaslu on 2021/9/7.
//

#import "DemoList3ViewController.h"

@interface DemoList3ViewController ()

@end

@implementation DemoList3ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"DemoList3";
    
    self.dataArray = @[
        [LXMDemoEntranceModel entranceModelWithName:@"Demo3_1ViewController"],
    ];
    
}
@end
