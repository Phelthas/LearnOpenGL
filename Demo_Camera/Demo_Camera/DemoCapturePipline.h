//
//  DemoCapturePipline.h
//  Demo_Camera
//
//  Created by billthaslu on 2021/4/2.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoCapturePipline : NSObject

@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;



- (void)startRunning;

- (void)stopRunning;

@end

NS_ASSUME_NONNULL_END
