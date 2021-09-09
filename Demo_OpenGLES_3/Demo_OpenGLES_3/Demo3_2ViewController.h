//
//  Demo3_2ViewController.h
//  Demo_OpenGLES_3
//
//  Created by billthaslu on 2021/9/7.
//

#import <UIKit/UIKit.h>
#import "Demo3GLView.h"

NS_ASSUME_NONNULL_BEGIN

@interface Demo3_2ViewController : UIViewController

@end


#pragma mark ----------------------------------Demo3_2GLView----------------------------------

@interface Demo3_2GLView : Demo3GLView

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END
