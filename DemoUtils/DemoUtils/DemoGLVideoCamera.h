//
//  DemoGLVideoCamera.h
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import "DemoGLOutput.h"
#import "DemoGLCapturePipline.h"

NS_ASSUME_NONNULL_BEGIN

@interface DemoGLVideoCamera : DemoGLOutput

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition;

- (void)setupAVCaptureConnectionWithBlock:(DemoGLCaptureConnectionConfigure)configureBlock;

- (void)startCameraCapture;

- (void)stopCameraCapture;

@end

NS_ASSUME_NONNULL_END
