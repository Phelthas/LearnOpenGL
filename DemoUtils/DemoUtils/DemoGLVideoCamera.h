//
//  DemoGLVideoCamera.h
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import "DemoGLOutput.h"
#import "DemoGLCapturePipline.h"

/**
 注意，匿名分类中的属性对于子类来说都是不可见的，要想子类继承的属性，必须在interface中声明！
 子类中即使有相同命名的属性，也不会覆盖，而是使用子类自己的实例变量，父类初始化的属性子类也用不到
 */

NS_ASSUME_NONNULL_BEGIN

@interface DemoGLVideoCamera : DemoGLOutput

@property (nonatomic, strong) DemoGLCapturePipline *capturePipline;

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition;

- (void)setupAVCaptureConnectionWithBlock:(DemoGLCaptureConnectionConfigure)configureBlock;

- (void)startCameraCapture;

- (void)stopCameraCapture;

@end

NS_ASSUME_NONNULL_END
