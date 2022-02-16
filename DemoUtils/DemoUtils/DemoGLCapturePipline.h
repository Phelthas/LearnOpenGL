//
//  DemoGLCapturePipline.h
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DemoGLCapturePipline;

@protocol DemoGLCapturePiplineDelegate <NSObject>

- (void)capturePipline:(DemoGLCapturePipline *)capturePipline didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end


@interface DemoGLCapturePipline : NSObject

@property (nonatomic, assign, readonly) BOOL isFullYUVRange;
@property (nonatomic, weak) id<DemoGLCapturePiplineDelegate> delegate;

- (instancetype)initWithCameraPosition:(AVCaptureDevicePosition)cameraPosition;

- (void)startRunning;

- (void)stopRunning;

@end

NS_ASSUME_NONNULL_END
