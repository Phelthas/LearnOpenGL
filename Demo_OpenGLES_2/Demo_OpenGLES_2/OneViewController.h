//
//  OneViewController.h
//  Demo_OpenGLES_2
//
//  Created by billthaslu on 2021/6/14.
//

#import <UIKit/UIKit.h>
#import "DemoGLView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OneViewController : UIViewController

@property (nonatomic, strong) DemoGLView *glView;

/// 子类可重载，会在ViewDidLoad中调用
- (void)setupGLView;

@end

NS_ASSUME_NONNULL_END
