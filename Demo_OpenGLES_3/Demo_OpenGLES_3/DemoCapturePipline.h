//
//  DemoCapturePipline.h
//  Demo_VideoCapture
//
//  Created by billthaslu on 2021/5/30.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


NS_ASSUME_NONNULL_BEGIN

@class DemoCapturePipline;

@protocol DemoCapturePiplineDelegate <NSObject>

- (void)capturePipline:(DemoCapturePipline *)capturePipline didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end

@interface DemoCapturePipline : NSObject

@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;
@property (nonatomic, weak) id<DemoCapturePiplineDelegate> delegate;


- (void)startRunning;

- (void)stopRunning;

@end

NS_ASSUME_NONNULL_END
