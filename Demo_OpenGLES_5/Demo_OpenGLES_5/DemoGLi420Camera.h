//
//  DemoGLi420Camera.h
//  Demo_OpenGLES_5
//
//  Created by billthaslu on 2022/3/3.
//

#import "DemoGLOutput.h"
#import "DemoGLCapturePipline.h"

NS_ASSUME_NONNULL_BEGIN

@interface DemoGLi420Camera : DemoGLOutput

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition;

- (void)setupAVCaptureConnectionWithBlock:(DemoGLCaptureConnectionConfigure)configureBlock;

- (void)startCameraCapture;

- (void)stopCameraCapture;

@end

NS_ASSUME_NONNULL_END
