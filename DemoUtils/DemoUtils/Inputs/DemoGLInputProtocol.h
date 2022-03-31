//
//  DemoGLInputProtocol.h
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "DemoGLFramebuffer.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DemoGLInputProtocol <NSObject>

- (void)newFrameReadyAtTime:(CMTime)frameTime timimgInfo:(CMSampleTimingInfo)timimgInfo;
- (void)setInputFramebuffer:(DemoGLFramebuffer *)framebuffer atIndex:(NSInteger)index;
- (void)setInputTextureSize:(CGSize)textureSize atIndex:(NSInteger)index;
- (NSInteger)nextAvailableTextureIndex;

@end

NS_ASSUME_NONNULL_END
