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
        [LXMDemoEntranceModel entranceModelWithName:@"TwoViewController" desc:nil],
    ];
    
}



@end
