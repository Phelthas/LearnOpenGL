//
//  DemoTestGLView.h
//  Demo_Camera
//
//  Created by billthaslu on 2021/4/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoTestGLView : UIView

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (BOOL)loadShaders;

- (BOOL)initializeBuffer;

@end

NS_ASSUME_NONNULL_END
