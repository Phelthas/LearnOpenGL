//
//  DemoGLInputProtocol.h
//  DemoUtils
//
//  Created by billthaslu on 2022/2/9.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "DemoGLTextureFrame.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DemoGLInputProtocol <NSObject>

- (void)newFrameReadyAtTime:(CMTime)frameTime timimgInfo:(CMSampleTimingInfo)timimgInfo;
- (void)setInputTexture:(DemoGLTextureFrame *)textureFrame atIndex:(NSInteger)index;
- (void)setInputTextureSize:(CGSize)textureSize atIndex:(NSInteger)index;
- (NSInteger)nextAvailableTextureIndex;

@end

NS_ASSUME_NONNULL_END
