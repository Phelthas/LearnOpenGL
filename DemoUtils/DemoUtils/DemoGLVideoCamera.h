//
//  DemoGLVideoCamera.h
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import "DemoGLOutput.h"

NS_ASSUME_NONNULL_BEGIN

@interface DemoGLVideoCamera : DemoGLOutput

- (void)startCameraCapture;

- (void)stopCameraCapture;

@end

NS_ASSUME_NONNULL_END
