//
//  DemoListXXXViewController.m
//  Demo_OpenGLES_6
//
//  Created by billthaslu on 2022/3/2.
//

#import "DemoList6ViewController.h"

@interface DemoList6ViewController ()

@end

@implementation DemoList6ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"DemoList6";
    
    self.dataArray = @[
        [LXMDemoEntranceModel entranceModelWithName:@"ViewController"],
        [LXMDemoEntranceModel entranceModelWithName:@"Demo6_1ViewController"],
        [LXMDemoEntranceModel entranceModelWithName:@"Demo6_2ViewController"],
        [LXMDemoEntranceModel entranceModelWithName:@"Demo6_3ViewController"],
        [LXMDemoEntranceModel entranceModelWithName:@"Demo6_4ViewController"],
        [LXMDemoEntranceModel entranceModelWithName:@"Demo6_5ViewController"],
        [LXMDemoEntranceModel entranceModelWithName:@"Demo6_6ViewController"],
        
    ];
    
}

@end
