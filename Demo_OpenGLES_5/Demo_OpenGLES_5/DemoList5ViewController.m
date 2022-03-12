//
//  DemoList5ViewController.m
//  Demo_OpenGLES_5
//
//  Created by billthaslu on 2022/3/1.
//

#import "DemoList5ViewController.h"

@interface DemoList5ViewController ()

@end

@implementation DemoList5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"DemoList5";
    
    self.dataArray = @[
        [LXMDemoEntranceModel entranceModelWithName:@"Demo5_TestViewController"],
        [LXMDemoEntranceModel entranceModelWithName:@"Demo5_1ViewController"],
        [LXMDemoEntranceModel entranceModelWithName:@"Demo5_2ViewController"],
        [LXMDemoEntranceModel entranceModelWithName:@"Demo5_3ViewController"],
        [LXMDemoEntranceModel entranceModelWithName:@"Demo5_4ViewController"],
        
    ];
    
}


@end
