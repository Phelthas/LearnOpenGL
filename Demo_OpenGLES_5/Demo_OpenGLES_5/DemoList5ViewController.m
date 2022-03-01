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
        
    ];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
